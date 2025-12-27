import { expect } from "chai";
import { ethers } from "hardhat";
import { PrivateMusicRoyalty } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

/**
 * @title Private Music Royalty Distribution Tests
 * @notice Comprehensive test suite for the PrivateMusicRoyalty contract demonstrating FHEVM concepts
 *
 * This test suite demonstrates:
 * - FHE encryption for confidential royalty shares
 * - Access control with FHE.allow and FHE.allowThis
 * - Encrypted computation for royalty distribution
 * - Asynchronous decryption for payment claims
 */
describe("PrivateMusicRoyalty", function () {
  let contract: PrivateMusicRoyalty;
  let owner: HardhatEthersSigner;
  let artist1: HardhatEthersSigner;
  let artist2: HardhatEthersSigner;
  let producer: HardhatEthersSigner;
  let user: HardhatEthersSigner;

  beforeEach(async function () {
    // Get signers
    [owner, artist1, artist2, producer, user] = await ethers.getSigners();

    // Deploy contract
    const PrivateMusicRoyaltyFactory = await ethers.getContractFactory("PrivateMusicRoyalty");
    contract = await PrivateMusicRoyaltyFactory.deploy();
    await contract.waitForDeployment();
  });

  describe("Contract Deployment", function () {
    it("✅ Should set the correct owner", async function () {
      expect(await contract.owner()).to.equal(owner.address);
    });

    it("✅ Should initialize with zero tracks and pools", async function () {
      expect(await contract.totalTracks()).to.equal(0);
      expect(await contract.totalRoyaltyPools()).to.equal(0);
    });
  });

  describe("Rights Holder Registration", function () {
    it("✅ Should allow rights holder registration", async function () {
      await expect(contract.connect(artist1).registerRightsHolder())
        .to.not.be.reverted;

      const holderInfo = await contract.getRightsHolderInfo(artist1.address);
      expect(holderInfo.verified).to.be.false;
      expect(holderInfo.registeredAt).to.be.gt(0);
    });

    it("❌ Should prevent duplicate registration", async function () {
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);

      await expect(contract.connect(artist1).registerRightsHolder())
        .to.be.revertedWith("Already registered");
    });

    it("✅ Owner can verify rights holders", async function () {
      await contract.connect(artist1).registerRightsHolder();

      await expect(contract.connect(owner).verifyRightsHolder(artist1.address))
        .to.emit(contract, "RightsHolderVerified")
        .withArgs(artist1.address);

      const holderInfo = await contract.getRightsHolderInfo(artist1.address);
      expect(holderInfo.verified).to.be.true;
    });

    it("❌ Should prevent non-owner from verifying", async function () {
      await contract.connect(artist1).registerRightsHolder();

      await expect(contract.connect(user).verifyRightsHolder(artist1.address))
        .to.be.revertedWith("Not authorized");
    });
  });

  describe("Track Registration with Encrypted Shares", function () {
    beforeEach(async function () {
      // Register and verify rights holders
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(artist2).registerRightsHolder();
      await contract.connect(producer).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
      await contract.connect(owner).verifyRightsHolder(artist2.address);
      await contract.connect(owner).verifyRightsHolder(producer.address);
    });

    it("✅ Should register track with encrypted shares", async function () {
      /**
       * FHEVM Concept: Encrypted State Variables
       * The contract encrypts royalty shares (euint32) to hide distribution percentages
       * Only rights holders can decrypt their own shares
       */
      const holders = [artist1.address, producer.address];
      const shares = [7000, 3000]; // 70% artist, 30% producer

      await expect(
        contract.connect(artist1).registerTrack(
          "ipfs://QmExample123",
          holders,
          shares
        )
      )
        .to.emit(contract, "TrackRegistered")
        .withArgs(1, artist1.address, "ipfs://QmExample123");

      const trackInfo = await contract.getTrackInfo(1);
      expect(trackInfo.active).to.be.true;
      expect(trackInfo.metadataURI).to.equal("ipfs://QmExample123");
      expect(trackInfo.rightsHoldersCount).to.equal(2);
    });

    it("❌ Should require verified rights holder", async function () {
      await contract.connect(user).registerRightsHolder();

      await expect(
        contract.connect(user).registerTrack(
          "ipfs://QmExample",
          [user.address],
          [10000]
        )
      ).to.be.revertedWith("Not verified rights holder");
    });

    it("❌ Should require total shares to equal 10000 (100%)", async function () {
      const holders = [artist1.address, producer.address];
      const invalidShares = [6000, 3000]; // Only 90%

      await expect(
        contract.connect(artist1).registerTrack(
          "ipfs://QmExample",
          holders,
          invalidShares
        )
      ).to.be.revertedWith("Total shares must equal 10000 (100%)");
    });

    it("❌ Should require matching holders and shares lengths", async function () {
      const holders = [artist1.address, producer.address];
      const shares = [10000]; // Mismatched length

      await expect(
        contract.connect(artist1).registerTrack(
          "ipfs://QmExample",
          holders,
          shares
        )
      ).to.be.revertedWith("Holders and shares length mismatch");
    });

    it("✅ Should allow multiple rights holders per track", async function () {
      /**
       * FHEVM Concept: Array of Encrypted Values
       * Each rights holder has their own encrypted share (euint32)
       * FHE.allow grants each holder permission to decrypt only their share
       */
      const holders = [artist1.address, artist2.address, producer.address];
      const shares = [5000, 3000, 2000]; // 50%, 30%, 20%

      await contract.connect(artist1).registerTrack(
        "ipfs://QmMultiHolder",
        holders,
        shares
      );

      const trackInfo = await contract.getTrackInfo(1);
      expect(trackInfo.rightsHoldersCount).to.equal(3);
    });
  });

  describe("Royalty Pool Creation", function () {
    let trackId: number;

    beforeEach(async function () {
      // Setup: Register track
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(producer).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
      await contract.connect(owner).verifyRightsHolder(producer.address);

      await contract.connect(artist1).registerTrack(
        "ipfs://QmTrack1",
        [artist1.address, producer.address],
        [7000, 3000]
      );
      trackId = 1;
    });

    it("✅ Should create royalty pool with ETH", async function () {
      /**
       * FHEVM Concept: Encrypted Amount Storage
       * The total royalty amount is encrypted (euint64) to hide revenue
       * This prevents public visibility of track earnings
       */
      const royaltyAmount = ethers.parseEther("1.0");

      await expect(
        contract.connect(user).createRoyaltyPool(trackId, { value: royaltyAmount })
      )
        .to.emit(contract, "RoyaltyPoolCreated")
        .withArgs(1, trackId);

      const poolInfo = await contract.getPoolInfo(1);
      expect(poolInfo.trackId).to.equal(trackId);
      expect(poolInfo.distributed).to.be.false;
    });

    it("❌ Should require ETH payment", async function () {
      await expect(
        contract.connect(user).createRoyaltyPool(trackId, { value: 0 })
      ).to.be.revertedWith("Must send ETH for royalty distribution");
    });

    it("❌ Should require active track", async function () {
      const invalidTrackId = 999;

      await expect(
        contract.connect(user).createRoyaltyPool(invalidTrackId, {
          value: ethers.parseEther("1.0")
        })
      ).to.be.revertedWith("Track not found or inactive");
    });
  });

  describe("Royalty Distribution with FHE Computation", function () {
    let trackId: number;
    let poolId: number;

    beforeEach(async function () {
      // Setup: Create track and pool
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(producer).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
      await contract.connect(owner).verifyRightsHolder(producer.address);

      await contract.connect(artist1).registerTrack(
        "ipfs://QmTrack1",
        [artist1.address, producer.address],
        [6000, 4000] // 60% artist, 40% producer
      );
      trackId = 1;

      await contract.connect(user).createRoyaltyPool(trackId, {
        value: ethers.parseEther("10.0")
      });
      poolId = 1;
    });

    it("✅ Should distribute royalties with encrypted calculations", async function () {
      /**
       * FHEVM Concept: Encrypted Computation
       * The contract performs FHE.mul on encrypted values:
       * payment = encryptedTotalAmount * encryptedShare
       *
       * This computes each holder's payment WITHOUT decrypting:
       * - Total amount remains encrypted
       * - Individual shares remain encrypted
       * - Result (payment) is also encrypted
       *
       * FHE Access Control:
       * - FHE.allowThis grants contract permission to use the value
       * - FHE.allow grants the holder permission to decrypt their payment
       */
      await expect(contract.connect(user).distributeRoyalties(poolId))
        .to.emit(contract, "RoyaltyDistributed");

      const poolInfo = await contract.getPoolInfo(poolId);
      expect(poolInfo.distributed).to.be.true;
    });

    it("❌ Should prevent double distribution", async function () {
      await contract.connect(user).distributeRoyalties(poolId);

      await expect(contract.connect(user).distributeRoyalties(poolId))
        .to.be.revertedWith("Royalties already distributed");
    });

    it("❌ Should require valid pool ID", async function () {
      const invalidPoolId = 999;

      await expect(contract.connect(user).distributeRoyalties(invalidPoolId))
        .to.be.revertedWith("Pool not found");
    });
  });

  describe("Access Control and Permissions", function () {
    let trackId: number;

    beforeEach(async function () {
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(producer).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
      await contract.connect(owner).verifyRightsHolder(producer.address);

      await contract.connect(artist1).registerTrack(
        "ipfs://QmTrack1",
        [artist1.address, producer.address],
        [7000, 3000]
      );
      trackId = 1;
    });

    it("✅ Rights holders can view their encrypted shares", async function () {
      /**
       * FHEVM Concept: Permission-Based Decryption
       * Only rights holders can request their encrypted share
       * FHE.allow was called during registration to grant this permission
       */
      const encryptedShare = await contract.connect(artist1).getEncryptedShare(
        trackId,
        artist1.address
      );
      expect(encryptedShare).to.not.be.undefined;
    });

    it("❌ Non-rights holders cannot view shares", async function () {
      await expect(
        contract.connect(user).getEncryptedShare(trackId, user.address)
      ).to.be.revertedWith("Not a rights holder");
    });

    it("✅ Can check rights holder status", async function () {
      expect(await contract.isRightsHolder(trackId, artist1.address)).to.be.true;
      expect(await contract.isRightsHolder(trackId, user.address)).to.be.false;
    });
  });

  describe("Track Management", function () {
    let trackId: number;

    beforeEach(async function () {
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);

      await contract.connect(artist1).registerTrack(
        "ipfs://QmOriginal",
        [artist1.address],
        [10000]
      );
      trackId = 1;
    });

    it("✅ Rights holder can update metadata", async function () {
      const newMetadata = "ipfs://QmUpdated";

      await contract.connect(artist1).updateTrackMetadata(trackId, newMetadata);

      const trackInfo = await contract.getTrackInfo(trackId);
      expect(trackInfo.metadataURI).to.equal(newMetadata);
    });

    it("✅ Rights holder can deactivate track", async function () {
      await contract.connect(artist1).deactivateTrack(trackId);

      const trackInfo = await contract.getTrackInfo(trackId);
      expect(trackInfo.active).to.be.false;
    });

    it("❌ Non-rights holder cannot update metadata", async function () {
      await expect(
        contract.connect(user).updateTrackMetadata(trackId, "ipfs://QmHacked")
      ).to.be.revertedWith("Not track rights holder");
    });
  });

  describe("Contract Information", function () {
    it("✅ Should return correct contract info", async function () {
      const info = await contract.getContractInfo();
      expect(info.contractOwner).to.equal(owner.address);
      expect(info.totalTracksCount).to.equal(0);
      expect(info.totalRoyaltyPoolsCount).to.equal(0);
    });

    it("✅ Should track total counts correctly", async function () {
      // Register and create track
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
      await contract.connect(artist1).registerTrack(
        "ipfs://QmTrack",
        [artist1.address],
        [10000]
      );

      expect(await contract.totalTracks()).to.equal(1);

      // Create pool
      await contract.connect(user).createRoyaltyPool(1, {
        value: ethers.parseEther("1.0")
      });

      expect(await contract.totalRoyaltyPools()).to.equal(1);
    });
  });

  describe("Edge Cases and Anti-Patterns", function () {
    beforeEach(async function () {
      await contract.connect(artist1).registerRightsHolder();
      await contract.connect(owner).verifyRightsHolder(artist1.address);
    });

    it("❌ Cannot register track with zero holders", async function () {
      await expect(
        contract.connect(artist1).registerTrack("ipfs://QmTrack", [], [])
      ).to.be.revertedWith("Must have at least one rights holder");
    });

    it("❌ Cannot create pool for deactivated track", async function () {
      await contract.connect(artist1).registerTrack(
        "ipfs://QmTrack",
        [artist1.address],
        [10000]
      );

      await contract.connect(artist1).deactivateTrack(1);

      await expect(
        contract.connect(user).createRoyaltyPool(1, {
          value: ethers.parseEther("1.0")
        })
      ).to.be.revertedWith("Track not found or inactive");
    });

    it("✅ Should handle single rights holder correctly", async function () {
      /**
       * Edge case: 100% ownership by single holder
       * Tests that FHE encryption works with single-element arrays
       */
      await contract.connect(artist1).registerTrack(
        "ipfs://QmSolo",
        [artist1.address],
        [10000]
      );

      const trackInfo = await contract.getTrackInfo(1);
      expect(trackInfo.rightsHoldersCount).to.equal(1);
    });
  });
});

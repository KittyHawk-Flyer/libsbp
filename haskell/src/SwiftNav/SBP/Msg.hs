{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# LANGUAGE NoImplicitPrelude           #-}
{-# LANGUAGE TemplateHaskell             #-}
{-# LANGUAGE RecordWildCards             #-}
{-# LANGUAGE OverloadedStrings           #-}

-- |
-- Module:      SwiftNav.SBP.Msg
-- Copyright:   Copyright (C) 2015 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Mark Fine <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- SBP message containers.

module SwiftNav.SBP.Msg
  ( module SwiftNav.SBP.Msg
  ) where

import BasicPrelude
import Control.Lens
import Data.Aeson               hiding (decode)
import Data.Aeson.Lens
import Data.Binary
import Data.ByteString.Lazy     hiding (ByteString)
import SwiftNav.SBP.Acquisition
import SwiftNav.SBP.Bootload
import SwiftNav.SBP.ExtEvents
import SwiftNav.SBP.FileIo
import SwiftNav.SBP.Flash
import SwiftNav.SBP.Gnss
import SwiftNav.SBP.Imu
import SwiftNav.SBP.Logging
import SwiftNav.SBP.Navigation
import SwiftNav.SBP.Ndb
import SwiftNav.SBP.Observation
import SwiftNav.SBP.Piksi
import SwiftNav.SBP.Settings
import SwiftNav.SBP.System
import SwiftNav.SBP.Tracking
import SwiftNav.SBP.User
import SwiftNav.SBP.Types


-- | An SBP message ADT composed of all defined SBP messages.
--
-- Includes SBPMsgUnknown for valid SBP messages with undefined message
-- types and SBPMsgBadCRC for SBP messages with invalid CRC checksums.
data SBPMsg =
     SBPMsgAcqResult MsgAcqResult Msg
   | SBPMsgAcqResultDepA MsgAcqResultDepA Msg
   | SBPMsgAcqResultDepB MsgAcqResultDepB Msg
   | SBPMsgAcqSvProfile MsgAcqSvProfile Msg
   | SBPMsgAgeCorrections MsgAgeCorrections Msg
   | SBPMsgAlmanac MsgAlmanac Msg
   | SBPMsgAlmanacGlo MsgAlmanacGlo Msg
   | SBPMsgAlmanacGps MsgAlmanacGps Msg
   | SBPMsgBasePosEcef MsgBasePosEcef Msg
   | SBPMsgBasePosLlh MsgBasePosLlh Msg
   | SBPMsgBaselineEcef MsgBaselineEcef Msg
   | SBPMsgBaselineEcefDepA MsgBaselineEcefDepA Msg
   | SBPMsgBaselineHeading MsgBaselineHeading Msg
   | SBPMsgBaselineHeadingDepA MsgBaselineHeadingDepA Msg
   | SBPMsgBaselineNed MsgBaselineNed Msg
   | SBPMsgBaselineNedDepA MsgBaselineNedDepA Msg
   | SBPMsgBootloaderHandshakeDepA MsgBootloaderHandshakeDepA Msg
   | SBPMsgBootloaderHandshakeReq MsgBootloaderHandshakeReq Msg
   | SBPMsgBootloaderHandshakeResp MsgBootloaderHandshakeResp Msg
   | SBPMsgBootloaderJumpToApp MsgBootloaderJumpToApp Msg
   | SBPMsgCommandOutput MsgCommandOutput Msg
   | SBPMsgCommandReq MsgCommandReq Msg
   | SBPMsgCommandResp MsgCommandResp Msg
   | SBPMsgCwResults MsgCwResults Msg
   | SBPMsgCwStart MsgCwStart Msg
   | SBPMsgDeviceMonitor MsgDeviceMonitor Msg
   | SBPMsgDgnssStatus MsgDgnssStatus Msg
   | SBPMsgDops MsgDops Msg
   | SBPMsgDopsDepA MsgDopsDepA Msg
   | SBPMsgEphemerisDepA MsgEphemerisDepA Msg
   | SBPMsgEphemerisDepB MsgEphemerisDepB Msg
   | SBPMsgEphemerisDepC MsgEphemerisDepC Msg
   | SBPMsgEphemerisDepD MsgEphemerisDepD Msg
   | SBPMsgEphemerisGlo MsgEphemerisGlo Msg
   | SBPMsgEphemerisGloDepA MsgEphemerisGloDepA Msg
   | SBPMsgEphemerisGloDepB MsgEphemerisGloDepB Msg
   | SBPMsgEphemerisGloDepC MsgEphemerisGloDepC Msg
   | SBPMsgEphemerisGps MsgEphemerisGps Msg
   | SBPMsgEphemerisGpsDepE MsgEphemerisGpsDepE Msg
   | SBPMsgEphemerisSbas MsgEphemerisSbas Msg
   | SBPMsgEphemerisSbasDepA MsgEphemerisSbasDepA Msg
   | SBPMsgExtEvent MsgExtEvent Msg
   | SBPMsgFileioReadDirReq MsgFileioReadDirReq Msg
   | SBPMsgFileioReadDirResp MsgFileioReadDirResp Msg
   | SBPMsgFileioReadReq MsgFileioReadReq Msg
   | SBPMsgFileioReadResp MsgFileioReadResp Msg
   | SBPMsgFileioRemove MsgFileioRemove Msg
   | SBPMsgFileioWriteReq MsgFileioWriteReq Msg
   | SBPMsgFileioWriteResp MsgFileioWriteResp Msg
   | SBPMsgFlashDone MsgFlashDone Msg
   | SBPMsgFlashErase MsgFlashErase Msg
   | SBPMsgFlashProgram MsgFlashProgram Msg
   | SBPMsgFlashReadReq MsgFlashReadReq Msg
   | SBPMsgFlashReadResp MsgFlashReadResp Msg
   | SBPMsgFwd MsgFwd Msg
   | SBPMsgGpsTime MsgGpsTime Msg
   | SBPMsgGpsTimeDepA MsgGpsTimeDepA Msg
   | SBPMsgGroupDelay MsgGroupDelay Msg
   | SBPMsgGroupDelayDepA MsgGroupDelayDepA Msg
   | SBPMsgHeartbeat MsgHeartbeat Msg
   | SBPMsgIarState MsgIarState Msg
   | SBPMsgImuAux MsgImuAux Msg
   | SBPMsgImuRaw MsgImuRaw Msg
   | SBPMsgInitBase MsgInitBase Msg
   | SBPMsgIono MsgIono Msg
   | SBPMsgLog MsgLog Msg
   | SBPMsgM25FlashWriteStatus MsgM25FlashWriteStatus Msg
   | SBPMsgMaskSatellite MsgMaskSatellite Msg
   | SBPMsgNapDeviceDnaReq MsgNapDeviceDnaReq Msg
   | SBPMsgNapDeviceDnaResp MsgNapDeviceDnaResp Msg
   | SBPMsgNdbEvent MsgNdbEvent Msg
   | SBPMsgNetworkStateReq MsgNetworkStateReq Msg
   | SBPMsgNetworkStateResp MsgNetworkStateResp Msg
   | SBPMsgObs MsgObs Msg
   | SBPMsgObsDepA MsgObsDepA Msg
   | SBPMsgObsDepB MsgObsDepB Msg
   | SBPMsgObsDepC MsgObsDepC Msg
   | SBPMsgPosEcef MsgPosEcef Msg
   | SBPMsgPosEcefDepA MsgPosEcefDepA Msg
   | SBPMsgPosLlh MsgPosLlh Msg
   | SBPMsgPosLlhDepA MsgPosLlhDepA Msg
   | SBPMsgPrintDep MsgPrintDep Msg
   | SBPMsgReset MsgReset Msg
   | SBPMsgResetDep MsgResetDep Msg
   | SBPMsgResetFilters MsgResetFilters Msg
   | SBPMsgSetTime MsgSetTime Msg
   | SBPMsgSettingsReadByIndexDone MsgSettingsReadByIndexDone Msg
   | SBPMsgSettingsReadByIndexReq MsgSettingsReadByIndexReq Msg
   | SBPMsgSettingsReadByIndexResp MsgSettingsReadByIndexResp Msg
   | SBPMsgSettingsReadReq MsgSettingsReadReq Msg
   | SBPMsgSettingsReadResp MsgSettingsReadResp Msg
   | SBPMsgSettingsRegister MsgSettingsRegister Msg
   | SBPMsgSettingsSave MsgSettingsSave Msg
   | SBPMsgSettingsWrite MsgSettingsWrite Msg
   | SBPMsgSpecan MsgSpecan Msg
   | SBPMsgStartup MsgStartup Msg
   | SBPMsgStmFlashLockSector MsgStmFlashLockSector Msg
   | SBPMsgStmFlashUnlockSector MsgStmFlashUnlockSector Msg
   | SBPMsgStmUniqueIdReq MsgStmUniqueIdReq Msg
   | SBPMsgStmUniqueIdResp MsgStmUniqueIdResp Msg
   | SBPMsgSvConfigurationGps MsgSvConfigurationGps Msg
   | SBPMsgThreadState MsgThreadState Msg
   | SBPMsgTrackingIq MsgTrackingIq Msg
   | SBPMsgTrackingState MsgTrackingState Msg
   | SBPMsgTrackingStateDepA MsgTrackingStateDepA Msg
   | SBPMsgTrackingStateDepB MsgTrackingStateDepB Msg
   | SBPMsgTrackingStateDetailed MsgTrackingStateDetailed Msg
   | SBPMsgTweet MsgTweet Msg
   | SBPMsgUartState MsgUartState Msg
   | SBPMsgUartStateDepa MsgUartStateDepa Msg
   | SBPMsgUserData MsgUserData Msg
   | SBPMsgUtcTime MsgUtcTime Msg
   | SBPMsgVelEcef MsgVelEcef Msg
   | SBPMsgVelEcefDepA MsgVelEcefDepA Msg
   | SBPMsgVelNed MsgVelNed Msg
   | SBPMsgVelNedDepA MsgVelNedDepA Msg
   | SBPMsgBadCrc Msg
   | SBPMsgUnknown Msg
  deriving ( Show, Read, Eq )

$(makePrisms ''SBPMsg)

instance Binary SBPMsg where
  get = do
    preamble <- getWord8
    if preamble /= msgSBPPreamble then get else
      decoder <$> get where
        decoder m@Msg {..}
          | checkCrc m /= _msgSBPCrc = SBPMsgBadCrc m
          | _msgSBPType == msgAcqResult = SBPMsgAcqResult (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAcqResultDepA = SBPMsgAcqResultDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAcqResultDepB = SBPMsgAcqResultDepB (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAcqSvProfile = SBPMsgAcqSvProfile (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAgeCorrections = SBPMsgAgeCorrections (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAlmanac = SBPMsgAlmanac (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAlmanacGlo = SBPMsgAlmanacGlo (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgAlmanacGps = SBPMsgAlmanacGps (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBasePosEcef = SBPMsgBasePosEcef (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBasePosLlh = SBPMsgBasePosLlh (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineEcef = SBPMsgBaselineEcef (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineEcefDepA = SBPMsgBaselineEcefDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineHeading = SBPMsgBaselineHeading (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineHeadingDepA = SBPMsgBaselineHeadingDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineNed = SBPMsgBaselineNed (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBaselineNedDepA = SBPMsgBaselineNedDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBootloaderHandshakeDepA = SBPMsgBootloaderHandshakeDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBootloaderHandshakeReq = SBPMsgBootloaderHandshakeReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBootloaderHandshakeResp = SBPMsgBootloaderHandshakeResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgBootloaderJumpToApp = SBPMsgBootloaderJumpToApp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgCommandOutput = SBPMsgCommandOutput (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgCommandReq = SBPMsgCommandReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgCommandResp = SBPMsgCommandResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgCwResults = SBPMsgCwResults (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgCwStart = SBPMsgCwStart (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgDeviceMonitor = SBPMsgDeviceMonitor (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgDgnssStatus = SBPMsgDgnssStatus (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgDops = SBPMsgDops (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgDopsDepA = SBPMsgDopsDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisDepA = SBPMsgEphemerisDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisDepB = SBPMsgEphemerisDepB (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisDepC = SBPMsgEphemerisDepC (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisDepD = SBPMsgEphemerisDepD (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGlo = SBPMsgEphemerisGlo (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGloDepA = SBPMsgEphemerisGloDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGloDepB = SBPMsgEphemerisGloDepB (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGloDepC = SBPMsgEphemerisGloDepC (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGps = SBPMsgEphemerisGps (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisGpsDepE = SBPMsgEphemerisGpsDepE (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisSbas = SBPMsgEphemerisSbas (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgEphemerisSbasDepA = SBPMsgEphemerisSbasDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgExtEvent = SBPMsgExtEvent (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioReadDirReq = SBPMsgFileioReadDirReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioReadDirResp = SBPMsgFileioReadDirResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioReadReq = SBPMsgFileioReadReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioReadResp = SBPMsgFileioReadResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioRemove = SBPMsgFileioRemove (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioWriteReq = SBPMsgFileioWriteReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFileioWriteResp = SBPMsgFileioWriteResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFlashDone = SBPMsgFlashDone (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFlashErase = SBPMsgFlashErase (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFlashProgram = SBPMsgFlashProgram (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFlashReadReq = SBPMsgFlashReadReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFlashReadResp = SBPMsgFlashReadResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgFwd = SBPMsgFwd (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgGpsTime = SBPMsgGpsTime (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgGpsTimeDepA = SBPMsgGpsTimeDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgGroupDelay = SBPMsgGroupDelay (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgGroupDelayDepA = SBPMsgGroupDelayDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgHeartbeat = SBPMsgHeartbeat (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgIarState = SBPMsgIarState (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgImuAux = SBPMsgImuAux (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgImuRaw = SBPMsgImuRaw (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgInitBase = SBPMsgInitBase (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgIono = SBPMsgIono (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgLog = SBPMsgLog (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgM25FlashWriteStatus = SBPMsgM25FlashWriteStatus (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgMaskSatellite = SBPMsgMaskSatellite (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgNapDeviceDnaReq = SBPMsgNapDeviceDnaReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgNapDeviceDnaResp = SBPMsgNapDeviceDnaResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgNdbEvent = SBPMsgNdbEvent (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgNetworkStateReq = SBPMsgNetworkStateReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgNetworkStateResp = SBPMsgNetworkStateResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgObs = SBPMsgObs (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgObsDepA = SBPMsgObsDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgObsDepB = SBPMsgObsDepB (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgObsDepC = SBPMsgObsDepC (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgPosEcef = SBPMsgPosEcef (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgPosEcefDepA = SBPMsgPosEcefDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgPosLlh = SBPMsgPosLlh (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgPosLlhDepA = SBPMsgPosLlhDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgPrintDep = SBPMsgPrintDep (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgReset = SBPMsgReset (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgResetDep = SBPMsgResetDep (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgResetFilters = SBPMsgResetFilters (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSetTime = SBPMsgSetTime (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsReadByIndexDone = SBPMsgSettingsReadByIndexDone (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsReadByIndexReq = SBPMsgSettingsReadByIndexReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsReadByIndexResp = SBPMsgSettingsReadByIndexResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsReadReq = SBPMsgSettingsReadReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsReadResp = SBPMsgSettingsReadResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsRegister = SBPMsgSettingsRegister (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsSave = SBPMsgSettingsSave (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSettingsWrite = SBPMsgSettingsWrite (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSpecan = SBPMsgSpecan (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgStartup = SBPMsgStartup (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgStmFlashLockSector = SBPMsgStmFlashLockSector (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgStmFlashUnlockSector = SBPMsgStmFlashUnlockSector (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgStmUniqueIdReq = SBPMsgStmUniqueIdReq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgStmUniqueIdResp = SBPMsgStmUniqueIdResp (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgSvConfigurationGps = SBPMsgSvConfigurationGps (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgThreadState = SBPMsgThreadState (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTrackingIq = SBPMsgTrackingIq (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTrackingState = SBPMsgTrackingState (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTrackingStateDepA = SBPMsgTrackingStateDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTrackingStateDepB = SBPMsgTrackingStateDepB (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTrackingStateDetailed = SBPMsgTrackingStateDetailed (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgTweet = SBPMsgTweet (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgUartState = SBPMsgUartState (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgUartStateDepa = SBPMsgUartStateDepa (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgUserData = SBPMsgUserData (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgUtcTime = SBPMsgUtcTime (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgVelEcef = SBPMsgVelEcef (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgVelEcefDepA = SBPMsgVelEcefDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgVelNed = SBPMsgVelNed (decode (fromStrict (unBytes _msgSBPPayload))) m
          | _msgSBPType == msgVelNedDepA = SBPMsgVelNedDepA (decode (fromStrict (unBytes _msgSBPPayload))) m
          | otherwise = SBPMsgUnknown m

  put sm = do
    putWord8 msgSBPPreamble
    encoder sm where
      encoder (SBPMsgAcqResult _ m) = put m
      encoder (SBPMsgAcqResultDepA _ m) = put m
      encoder (SBPMsgAcqResultDepB _ m) = put m
      encoder (SBPMsgAcqSvProfile _ m) = put m
      encoder (SBPMsgAgeCorrections _ m) = put m
      encoder (SBPMsgAlmanac _ m) = put m
      encoder (SBPMsgAlmanacGlo _ m) = put m
      encoder (SBPMsgAlmanacGps _ m) = put m
      encoder (SBPMsgBasePosEcef _ m) = put m
      encoder (SBPMsgBasePosLlh _ m) = put m
      encoder (SBPMsgBaselineEcef _ m) = put m
      encoder (SBPMsgBaselineEcefDepA _ m) = put m
      encoder (SBPMsgBaselineHeading _ m) = put m
      encoder (SBPMsgBaselineHeadingDepA _ m) = put m
      encoder (SBPMsgBaselineNed _ m) = put m
      encoder (SBPMsgBaselineNedDepA _ m) = put m
      encoder (SBPMsgBootloaderHandshakeDepA _ m) = put m
      encoder (SBPMsgBootloaderHandshakeReq _ m) = put m
      encoder (SBPMsgBootloaderHandshakeResp _ m) = put m
      encoder (SBPMsgBootloaderJumpToApp _ m) = put m
      encoder (SBPMsgCommandOutput _ m) = put m
      encoder (SBPMsgCommandReq _ m) = put m
      encoder (SBPMsgCommandResp _ m) = put m
      encoder (SBPMsgCwResults _ m) = put m
      encoder (SBPMsgCwStart _ m) = put m
      encoder (SBPMsgDeviceMonitor _ m) = put m
      encoder (SBPMsgDgnssStatus _ m) = put m
      encoder (SBPMsgDops _ m) = put m
      encoder (SBPMsgDopsDepA _ m) = put m
      encoder (SBPMsgEphemerisDepA _ m) = put m
      encoder (SBPMsgEphemerisDepB _ m) = put m
      encoder (SBPMsgEphemerisDepC _ m) = put m
      encoder (SBPMsgEphemerisDepD _ m) = put m
      encoder (SBPMsgEphemerisGlo _ m) = put m
      encoder (SBPMsgEphemerisGloDepA _ m) = put m
      encoder (SBPMsgEphemerisGloDepB _ m) = put m
      encoder (SBPMsgEphemerisGloDepC _ m) = put m
      encoder (SBPMsgEphemerisGps _ m) = put m
      encoder (SBPMsgEphemerisGpsDepE _ m) = put m
      encoder (SBPMsgEphemerisSbas _ m) = put m
      encoder (SBPMsgEphemerisSbasDepA _ m) = put m
      encoder (SBPMsgExtEvent _ m) = put m
      encoder (SBPMsgFileioReadDirReq _ m) = put m
      encoder (SBPMsgFileioReadDirResp _ m) = put m
      encoder (SBPMsgFileioReadReq _ m) = put m
      encoder (SBPMsgFileioReadResp _ m) = put m
      encoder (SBPMsgFileioRemove _ m) = put m
      encoder (SBPMsgFileioWriteReq _ m) = put m
      encoder (SBPMsgFileioWriteResp _ m) = put m
      encoder (SBPMsgFlashDone _ m) = put m
      encoder (SBPMsgFlashErase _ m) = put m
      encoder (SBPMsgFlashProgram _ m) = put m
      encoder (SBPMsgFlashReadReq _ m) = put m
      encoder (SBPMsgFlashReadResp _ m) = put m
      encoder (SBPMsgFwd _ m) = put m
      encoder (SBPMsgGpsTime _ m) = put m
      encoder (SBPMsgGpsTimeDepA _ m) = put m
      encoder (SBPMsgGroupDelay _ m) = put m
      encoder (SBPMsgGroupDelayDepA _ m) = put m
      encoder (SBPMsgHeartbeat _ m) = put m
      encoder (SBPMsgIarState _ m) = put m
      encoder (SBPMsgImuAux _ m) = put m
      encoder (SBPMsgImuRaw _ m) = put m
      encoder (SBPMsgInitBase _ m) = put m
      encoder (SBPMsgIono _ m) = put m
      encoder (SBPMsgLog _ m) = put m
      encoder (SBPMsgM25FlashWriteStatus _ m) = put m
      encoder (SBPMsgMaskSatellite _ m) = put m
      encoder (SBPMsgNapDeviceDnaReq _ m) = put m
      encoder (SBPMsgNapDeviceDnaResp _ m) = put m
      encoder (SBPMsgNdbEvent _ m) = put m
      encoder (SBPMsgNetworkStateReq _ m) = put m
      encoder (SBPMsgNetworkStateResp _ m) = put m
      encoder (SBPMsgObs _ m) = put m
      encoder (SBPMsgObsDepA _ m) = put m
      encoder (SBPMsgObsDepB _ m) = put m
      encoder (SBPMsgObsDepC _ m) = put m
      encoder (SBPMsgPosEcef _ m) = put m
      encoder (SBPMsgPosEcefDepA _ m) = put m
      encoder (SBPMsgPosLlh _ m) = put m
      encoder (SBPMsgPosLlhDepA _ m) = put m
      encoder (SBPMsgPrintDep _ m) = put m
      encoder (SBPMsgReset _ m) = put m
      encoder (SBPMsgResetDep _ m) = put m
      encoder (SBPMsgResetFilters _ m) = put m
      encoder (SBPMsgSetTime _ m) = put m
      encoder (SBPMsgSettingsReadByIndexDone _ m) = put m
      encoder (SBPMsgSettingsReadByIndexReq _ m) = put m
      encoder (SBPMsgSettingsReadByIndexResp _ m) = put m
      encoder (SBPMsgSettingsReadReq _ m) = put m
      encoder (SBPMsgSettingsReadResp _ m) = put m
      encoder (SBPMsgSettingsRegister _ m) = put m
      encoder (SBPMsgSettingsSave _ m) = put m
      encoder (SBPMsgSettingsWrite _ m) = put m
      encoder (SBPMsgSpecan _ m) = put m
      encoder (SBPMsgStartup _ m) = put m
      encoder (SBPMsgStmFlashLockSector _ m) = put m
      encoder (SBPMsgStmFlashUnlockSector _ m) = put m
      encoder (SBPMsgStmUniqueIdReq _ m) = put m
      encoder (SBPMsgStmUniqueIdResp _ m) = put m
      encoder (SBPMsgSvConfigurationGps _ m) = put m
      encoder (SBPMsgThreadState _ m) = put m
      encoder (SBPMsgTrackingIq _ m) = put m
      encoder (SBPMsgTrackingState _ m) = put m
      encoder (SBPMsgTrackingStateDepA _ m) = put m
      encoder (SBPMsgTrackingStateDepB _ m) = put m
      encoder (SBPMsgTrackingStateDetailed _ m) = put m
      encoder (SBPMsgTweet _ m) = put m
      encoder (SBPMsgUartState _ m) = put m
      encoder (SBPMsgUartStateDepa _ m) = put m
      encoder (SBPMsgUserData _ m) = put m
      encoder (SBPMsgUtcTime _ m) = put m
      encoder (SBPMsgVelEcef _ m) = put m
      encoder (SBPMsgVelEcefDepA _ m) = put m
      encoder (SBPMsgVelNed _ m) = put m
      encoder (SBPMsgVelNedDepA _ m) = put m
      encoder (SBPMsgUnknown m) = put m
      encoder (SBPMsgBadCrc m) = put m

instance FromJSON SBPMsg where
  parseJSON obj@(Object o) = do
    msgType <- o .: "msg_type"
    payload <- o .: "payload"
    decoder msgType payload where
      decoder msgType payload
        | msgType == msgAcqResult = SBPMsgAcqResult <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAcqResultDepA = SBPMsgAcqResultDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAcqResultDepB = SBPMsgAcqResultDepB <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAcqSvProfile = SBPMsgAcqSvProfile <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAgeCorrections = SBPMsgAgeCorrections <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAlmanac = SBPMsgAlmanac <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAlmanacGlo = SBPMsgAlmanacGlo <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgAlmanacGps = SBPMsgAlmanacGps <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBasePosEcef = SBPMsgBasePosEcef <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBasePosLlh = SBPMsgBasePosLlh <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineEcef = SBPMsgBaselineEcef <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineEcefDepA = SBPMsgBaselineEcefDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineHeading = SBPMsgBaselineHeading <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineHeadingDepA = SBPMsgBaselineHeadingDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineNed = SBPMsgBaselineNed <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBaselineNedDepA = SBPMsgBaselineNedDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBootloaderHandshakeDepA = SBPMsgBootloaderHandshakeDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBootloaderHandshakeReq = SBPMsgBootloaderHandshakeReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBootloaderHandshakeResp = SBPMsgBootloaderHandshakeResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgBootloaderJumpToApp = SBPMsgBootloaderJumpToApp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgCommandOutput = SBPMsgCommandOutput <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgCommandReq = SBPMsgCommandReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgCommandResp = SBPMsgCommandResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgCwResults = SBPMsgCwResults <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgCwStart = SBPMsgCwStart <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgDeviceMonitor = SBPMsgDeviceMonitor <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgDgnssStatus = SBPMsgDgnssStatus <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgDops = SBPMsgDops <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgDopsDepA = SBPMsgDopsDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisDepA = SBPMsgEphemerisDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisDepB = SBPMsgEphemerisDepB <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisDepC = SBPMsgEphemerisDepC <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisDepD = SBPMsgEphemerisDepD <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGlo = SBPMsgEphemerisGlo <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGloDepA = SBPMsgEphemerisGloDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGloDepB = SBPMsgEphemerisGloDepB <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGloDepC = SBPMsgEphemerisGloDepC <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGps = SBPMsgEphemerisGps <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisGpsDepE = SBPMsgEphemerisGpsDepE <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisSbas = SBPMsgEphemerisSbas <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgEphemerisSbasDepA = SBPMsgEphemerisSbasDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgExtEvent = SBPMsgExtEvent <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioReadDirReq = SBPMsgFileioReadDirReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioReadDirResp = SBPMsgFileioReadDirResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioReadReq = SBPMsgFileioReadReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioReadResp = SBPMsgFileioReadResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioRemove = SBPMsgFileioRemove <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioWriteReq = SBPMsgFileioWriteReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFileioWriteResp = SBPMsgFileioWriteResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFlashDone = SBPMsgFlashDone <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFlashErase = SBPMsgFlashErase <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFlashProgram = SBPMsgFlashProgram <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFlashReadReq = SBPMsgFlashReadReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFlashReadResp = SBPMsgFlashReadResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgFwd = SBPMsgFwd <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgGpsTime = SBPMsgGpsTime <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgGpsTimeDepA = SBPMsgGpsTimeDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgGroupDelay = SBPMsgGroupDelay <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgGroupDelayDepA = SBPMsgGroupDelayDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgHeartbeat = SBPMsgHeartbeat <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgIarState = SBPMsgIarState <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgImuAux = SBPMsgImuAux <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgImuRaw = SBPMsgImuRaw <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgInitBase = SBPMsgInitBase <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgIono = SBPMsgIono <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgLog = SBPMsgLog <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgM25FlashWriteStatus = SBPMsgM25FlashWriteStatus <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgMaskSatellite = SBPMsgMaskSatellite <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgNapDeviceDnaReq = SBPMsgNapDeviceDnaReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgNapDeviceDnaResp = SBPMsgNapDeviceDnaResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgNdbEvent = SBPMsgNdbEvent <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgNetworkStateReq = SBPMsgNetworkStateReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgNetworkStateResp = SBPMsgNetworkStateResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgObs = SBPMsgObs <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgObsDepA = SBPMsgObsDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgObsDepB = SBPMsgObsDepB <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgObsDepC = SBPMsgObsDepC <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgPosEcef = SBPMsgPosEcef <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgPosEcefDepA = SBPMsgPosEcefDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgPosLlh = SBPMsgPosLlh <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgPosLlhDepA = SBPMsgPosLlhDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgPrintDep = SBPMsgPrintDep <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgReset = SBPMsgReset <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgResetDep = SBPMsgResetDep <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgResetFilters = SBPMsgResetFilters <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSetTime = SBPMsgSetTime <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsReadByIndexDone = SBPMsgSettingsReadByIndexDone <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsReadByIndexReq = SBPMsgSettingsReadByIndexReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsReadByIndexResp = SBPMsgSettingsReadByIndexResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsReadReq = SBPMsgSettingsReadReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsReadResp = SBPMsgSettingsReadResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsRegister = SBPMsgSettingsRegister <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsSave = SBPMsgSettingsSave <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSettingsWrite = SBPMsgSettingsWrite <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSpecan = SBPMsgSpecan <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgStartup = SBPMsgStartup <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgStmFlashLockSector = SBPMsgStmFlashLockSector <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgStmFlashUnlockSector = SBPMsgStmFlashUnlockSector <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgStmUniqueIdReq = SBPMsgStmUniqueIdReq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgStmUniqueIdResp = SBPMsgStmUniqueIdResp <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgSvConfigurationGps = SBPMsgSvConfigurationGps <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgThreadState = SBPMsgThreadState <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTrackingIq = SBPMsgTrackingIq <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTrackingState = SBPMsgTrackingState <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTrackingStateDepA = SBPMsgTrackingStateDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTrackingStateDepB = SBPMsgTrackingStateDepB <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTrackingStateDetailed = SBPMsgTrackingStateDetailed <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgTweet = SBPMsgTweet <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgUartState = SBPMsgUartState <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgUartStateDepa = SBPMsgUartStateDepa <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgUserData = SBPMsgUserData <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgUtcTime = SBPMsgUtcTime <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgVelEcef = SBPMsgVelEcef <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgVelEcefDepA = SBPMsgVelEcefDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgVelNed = SBPMsgVelNed <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | msgType == msgVelNedDepA = SBPMsgVelNedDepA <$> pure (decode (fromStrict (unBytes payload))) <*> parseJSON obj
        | otherwise = SBPMsgUnknown <$> parseJSON obj
  parseJSON _ = mzero

(<<>>) :: Value -> Value -> Value
(<<>>) a b = fromMaybe Null $ do
  a' <- preview _Object a
  b' <- preview _Object b
  pure $ review _Object $ a' <> b'

instance ToJSON SBPMsg where
  toJSON (SBPMsgAcqResult n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAcqResultDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAcqResultDepB n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAcqSvProfile n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAgeCorrections n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAlmanac n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAlmanacGlo n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgAlmanacGps n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBasePosEcef n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBasePosLlh n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineEcef n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineEcefDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineHeading n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineHeadingDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineNed n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBaselineNedDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBootloaderHandshakeDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBootloaderHandshakeReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBootloaderHandshakeResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBootloaderJumpToApp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgCommandOutput n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgCommandReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgCommandResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgCwResults n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgCwStart n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgDeviceMonitor n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgDgnssStatus n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgDops n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgDopsDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisDepB n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisDepC n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisDepD n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGlo n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGloDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGloDepB n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGloDepC n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGps n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisGpsDepE n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisSbas n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgEphemerisSbasDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgExtEvent n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioReadDirReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioReadDirResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioReadReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioReadResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioRemove n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioWriteReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFileioWriteResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFlashDone n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFlashErase n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFlashProgram n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFlashReadReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFlashReadResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgFwd n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgGpsTime n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgGpsTimeDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgGroupDelay n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgGroupDelayDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgHeartbeat n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgIarState n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgImuAux n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgImuRaw n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgInitBase n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgIono n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgLog n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgM25FlashWriteStatus n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgMaskSatellite n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgNapDeviceDnaReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgNapDeviceDnaResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgNdbEvent n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgNetworkStateReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgNetworkStateResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgObs n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgObsDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgObsDepB n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgObsDepC n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgPosEcef n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgPosEcefDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgPosLlh n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgPosLlhDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgPrintDep n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgReset n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgResetDep n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgResetFilters n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSetTime n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsReadByIndexDone n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsReadByIndexReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsReadByIndexResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsReadReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsReadResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsRegister n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsSave n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSettingsWrite n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSpecan n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgStartup n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgStmFlashLockSector n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgStmFlashUnlockSector n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgStmUniqueIdReq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgStmUniqueIdResp n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgSvConfigurationGps n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgThreadState n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTrackingIq n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTrackingState n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTrackingStateDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTrackingStateDepB n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTrackingStateDetailed n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgTweet n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgUartState n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgUartStateDepa n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgUserData n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgUtcTime n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgVelEcef n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgVelEcefDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgVelNed n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgVelNedDepA n m) = toJSON n <<>> toJSON m
  toJSON (SBPMsgBadCrc m) = toJSON m
  toJSON (SBPMsgUnknown m) = toJSON m

instance HasMsg SBPMsg where
  msg f (SBPMsgAcqResult n m) = SBPMsgAcqResult n <$> f m
  msg f (SBPMsgAcqResultDepA n m) = SBPMsgAcqResultDepA n <$> f m
  msg f (SBPMsgAcqResultDepB n m) = SBPMsgAcqResultDepB n <$> f m
  msg f (SBPMsgAcqSvProfile n m) = SBPMsgAcqSvProfile n <$> f m
  msg f (SBPMsgAgeCorrections n m) = SBPMsgAgeCorrections n <$> f m
  msg f (SBPMsgAlmanac n m) = SBPMsgAlmanac n <$> f m
  msg f (SBPMsgAlmanacGlo n m) = SBPMsgAlmanacGlo n <$> f m
  msg f (SBPMsgAlmanacGps n m) = SBPMsgAlmanacGps n <$> f m
  msg f (SBPMsgBasePosEcef n m) = SBPMsgBasePosEcef n <$> f m
  msg f (SBPMsgBasePosLlh n m) = SBPMsgBasePosLlh n <$> f m
  msg f (SBPMsgBaselineEcef n m) = SBPMsgBaselineEcef n <$> f m
  msg f (SBPMsgBaselineEcefDepA n m) = SBPMsgBaselineEcefDepA n <$> f m
  msg f (SBPMsgBaselineHeading n m) = SBPMsgBaselineHeading n <$> f m
  msg f (SBPMsgBaselineHeadingDepA n m) = SBPMsgBaselineHeadingDepA n <$> f m
  msg f (SBPMsgBaselineNed n m) = SBPMsgBaselineNed n <$> f m
  msg f (SBPMsgBaselineNedDepA n m) = SBPMsgBaselineNedDepA n <$> f m
  msg f (SBPMsgBootloaderHandshakeDepA n m) = SBPMsgBootloaderHandshakeDepA n <$> f m
  msg f (SBPMsgBootloaderHandshakeReq n m) = SBPMsgBootloaderHandshakeReq n <$> f m
  msg f (SBPMsgBootloaderHandshakeResp n m) = SBPMsgBootloaderHandshakeResp n <$> f m
  msg f (SBPMsgBootloaderJumpToApp n m) = SBPMsgBootloaderJumpToApp n <$> f m
  msg f (SBPMsgCommandOutput n m) = SBPMsgCommandOutput n <$> f m
  msg f (SBPMsgCommandReq n m) = SBPMsgCommandReq n <$> f m
  msg f (SBPMsgCommandResp n m) = SBPMsgCommandResp n <$> f m
  msg f (SBPMsgCwResults n m) = SBPMsgCwResults n <$> f m
  msg f (SBPMsgCwStart n m) = SBPMsgCwStart n <$> f m
  msg f (SBPMsgDeviceMonitor n m) = SBPMsgDeviceMonitor n <$> f m
  msg f (SBPMsgDgnssStatus n m) = SBPMsgDgnssStatus n <$> f m
  msg f (SBPMsgDops n m) = SBPMsgDops n <$> f m
  msg f (SBPMsgDopsDepA n m) = SBPMsgDopsDepA n <$> f m
  msg f (SBPMsgEphemerisDepA n m) = SBPMsgEphemerisDepA n <$> f m
  msg f (SBPMsgEphemerisDepB n m) = SBPMsgEphemerisDepB n <$> f m
  msg f (SBPMsgEphemerisDepC n m) = SBPMsgEphemerisDepC n <$> f m
  msg f (SBPMsgEphemerisDepD n m) = SBPMsgEphemerisDepD n <$> f m
  msg f (SBPMsgEphemerisGlo n m) = SBPMsgEphemerisGlo n <$> f m
  msg f (SBPMsgEphemerisGloDepA n m) = SBPMsgEphemerisGloDepA n <$> f m
  msg f (SBPMsgEphemerisGloDepB n m) = SBPMsgEphemerisGloDepB n <$> f m
  msg f (SBPMsgEphemerisGloDepC n m) = SBPMsgEphemerisGloDepC n <$> f m
  msg f (SBPMsgEphemerisGps n m) = SBPMsgEphemerisGps n <$> f m
  msg f (SBPMsgEphemerisGpsDepE n m) = SBPMsgEphemerisGpsDepE n <$> f m
  msg f (SBPMsgEphemerisSbas n m) = SBPMsgEphemerisSbas n <$> f m
  msg f (SBPMsgEphemerisSbasDepA n m) = SBPMsgEphemerisSbasDepA n <$> f m
  msg f (SBPMsgExtEvent n m) = SBPMsgExtEvent n <$> f m
  msg f (SBPMsgFileioReadDirReq n m) = SBPMsgFileioReadDirReq n <$> f m
  msg f (SBPMsgFileioReadDirResp n m) = SBPMsgFileioReadDirResp n <$> f m
  msg f (SBPMsgFileioReadReq n m) = SBPMsgFileioReadReq n <$> f m
  msg f (SBPMsgFileioReadResp n m) = SBPMsgFileioReadResp n <$> f m
  msg f (SBPMsgFileioRemove n m) = SBPMsgFileioRemove n <$> f m
  msg f (SBPMsgFileioWriteReq n m) = SBPMsgFileioWriteReq n <$> f m
  msg f (SBPMsgFileioWriteResp n m) = SBPMsgFileioWriteResp n <$> f m
  msg f (SBPMsgFlashDone n m) = SBPMsgFlashDone n <$> f m
  msg f (SBPMsgFlashErase n m) = SBPMsgFlashErase n <$> f m
  msg f (SBPMsgFlashProgram n m) = SBPMsgFlashProgram n <$> f m
  msg f (SBPMsgFlashReadReq n m) = SBPMsgFlashReadReq n <$> f m
  msg f (SBPMsgFlashReadResp n m) = SBPMsgFlashReadResp n <$> f m
  msg f (SBPMsgFwd n m) = SBPMsgFwd n <$> f m
  msg f (SBPMsgGpsTime n m) = SBPMsgGpsTime n <$> f m
  msg f (SBPMsgGpsTimeDepA n m) = SBPMsgGpsTimeDepA n <$> f m
  msg f (SBPMsgGroupDelay n m) = SBPMsgGroupDelay n <$> f m
  msg f (SBPMsgGroupDelayDepA n m) = SBPMsgGroupDelayDepA n <$> f m
  msg f (SBPMsgHeartbeat n m) = SBPMsgHeartbeat n <$> f m
  msg f (SBPMsgIarState n m) = SBPMsgIarState n <$> f m
  msg f (SBPMsgImuAux n m) = SBPMsgImuAux n <$> f m
  msg f (SBPMsgImuRaw n m) = SBPMsgImuRaw n <$> f m
  msg f (SBPMsgInitBase n m) = SBPMsgInitBase n <$> f m
  msg f (SBPMsgIono n m) = SBPMsgIono n <$> f m
  msg f (SBPMsgLog n m) = SBPMsgLog n <$> f m
  msg f (SBPMsgM25FlashWriteStatus n m) = SBPMsgM25FlashWriteStatus n <$> f m
  msg f (SBPMsgMaskSatellite n m) = SBPMsgMaskSatellite n <$> f m
  msg f (SBPMsgNapDeviceDnaReq n m) = SBPMsgNapDeviceDnaReq n <$> f m
  msg f (SBPMsgNapDeviceDnaResp n m) = SBPMsgNapDeviceDnaResp n <$> f m
  msg f (SBPMsgNdbEvent n m) = SBPMsgNdbEvent n <$> f m
  msg f (SBPMsgNetworkStateReq n m) = SBPMsgNetworkStateReq n <$> f m
  msg f (SBPMsgNetworkStateResp n m) = SBPMsgNetworkStateResp n <$> f m
  msg f (SBPMsgObs n m) = SBPMsgObs n <$> f m
  msg f (SBPMsgObsDepA n m) = SBPMsgObsDepA n <$> f m
  msg f (SBPMsgObsDepB n m) = SBPMsgObsDepB n <$> f m
  msg f (SBPMsgObsDepC n m) = SBPMsgObsDepC n <$> f m
  msg f (SBPMsgPosEcef n m) = SBPMsgPosEcef n <$> f m
  msg f (SBPMsgPosEcefDepA n m) = SBPMsgPosEcefDepA n <$> f m
  msg f (SBPMsgPosLlh n m) = SBPMsgPosLlh n <$> f m
  msg f (SBPMsgPosLlhDepA n m) = SBPMsgPosLlhDepA n <$> f m
  msg f (SBPMsgPrintDep n m) = SBPMsgPrintDep n <$> f m
  msg f (SBPMsgReset n m) = SBPMsgReset n <$> f m
  msg f (SBPMsgResetDep n m) = SBPMsgResetDep n <$> f m
  msg f (SBPMsgResetFilters n m) = SBPMsgResetFilters n <$> f m
  msg f (SBPMsgSetTime n m) = SBPMsgSetTime n <$> f m
  msg f (SBPMsgSettingsReadByIndexDone n m) = SBPMsgSettingsReadByIndexDone n <$> f m
  msg f (SBPMsgSettingsReadByIndexReq n m) = SBPMsgSettingsReadByIndexReq n <$> f m
  msg f (SBPMsgSettingsReadByIndexResp n m) = SBPMsgSettingsReadByIndexResp n <$> f m
  msg f (SBPMsgSettingsReadReq n m) = SBPMsgSettingsReadReq n <$> f m
  msg f (SBPMsgSettingsReadResp n m) = SBPMsgSettingsReadResp n <$> f m
  msg f (SBPMsgSettingsRegister n m) = SBPMsgSettingsRegister n <$> f m
  msg f (SBPMsgSettingsSave n m) = SBPMsgSettingsSave n <$> f m
  msg f (SBPMsgSettingsWrite n m) = SBPMsgSettingsWrite n <$> f m
  msg f (SBPMsgSpecan n m) = SBPMsgSpecan n <$> f m
  msg f (SBPMsgStartup n m) = SBPMsgStartup n <$> f m
  msg f (SBPMsgStmFlashLockSector n m) = SBPMsgStmFlashLockSector n <$> f m
  msg f (SBPMsgStmFlashUnlockSector n m) = SBPMsgStmFlashUnlockSector n <$> f m
  msg f (SBPMsgStmUniqueIdReq n m) = SBPMsgStmUniqueIdReq n <$> f m
  msg f (SBPMsgStmUniqueIdResp n m) = SBPMsgStmUniqueIdResp n <$> f m
  msg f (SBPMsgSvConfigurationGps n m) = SBPMsgSvConfigurationGps n <$> f m
  msg f (SBPMsgThreadState n m) = SBPMsgThreadState n <$> f m
  msg f (SBPMsgTrackingIq n m) = SBPMsgTrackingIq n <$> f m
  msg f (SBPMsgTrackingState n m) = SBPMsgTrackingState n <$> f m
  msg f (SBPMsgTrackingStateDepA n m) = SBPMsgTrackingStateDepA n <$> f m
  msg f (SBPMsgTrackingStateDepB n m) = SBPMsgTrackingStateDepB n <$> f m
  msg f (SBPMsgTrackingStateDetailed n m) = SBPMsgTrackingStateDetailed n <$> f m
  msg f (SBPMsgTweet n m) = SBPMsgTweet n <$> f m
  msg f (SBPMsgUartState n m) = SBPMsgUartState n <$> f m
  msg f (SBPMsgUartStateDepa n m) = SBPMsgUartStateDepa n <$> f m
  msg f (SBPMsgUserData n m) = SBPMsgUserData n <$> f m
  msg f (SBPMsgUtcTime n m) = SBPMsgUtcTime n <$> f m
  msg f (SBPMsgVelEcef n m) = SBPMsgVelEcef n <$> f m
  msg f (SBPMsgVelEcefDepA n m) = SBPMsgVelEcefDepA n <$> f m
  msg f (SBPMsgVelNed n m) = SBPMsgVelNed n <$> f m
  msg f (SBPMsgVelNedDepA n m) = SBPMsgVelNedDepA n <$> f m
  msg f (SBPMsgUnknown m) = SBPMsgUnknown <$> f m
  msg f (SBPMsgBadCrc m) = SBPMsgBadCrc <$> f m
{-# LANGUAGE DeriveFunctor #-}

module Transport where

import Control.Comonad
import qualified Data.Text as T
import Data.Maybe
import Safe
import Control.Concurrent.STM
import Irc.RawIrcMsg (RawIrcMsg)

type IncomingQueue = TQueue Irc.RawIrcMsg.RawIrcMsg
type OutcomingQueue = TQueue Irc.RawIrcMsg.RawIrcMsg

data Sender = Sender
  { senderName :: T.Text
  , senderDisplayName :: T.Text
  , senderChannel :: T.Text
  , senderSubscriber :: Bool
  , senderMod :: Bool
  , senderBroadcaster :: Bool
  , senderOwner :: Bool
  }

senderAuthority :: Sender -> Bool
senderAuthority sender =
  senderMod sender || senderBroadcaster sender || senderOwner sender

data Event
  = Joined T.Text
  | Msg Sender
        T.Text

data Message a = Message
  { messageSender :: Sender
  , messageContent :: a
  } deriving (Functor)

instance Comonad Message where
  extract = messageContent
  duplicate m = m <$ m

channelOfMessage :: Message a -> T.Text
channelOfMessage Message {messageSender = sender} =
  T.pack $ fromMaybe "tsoding" $ tailMay $ T.unpack $ senderChannel sender



module Main
    ( main
    ) where

import Data.String        (IsString (..))
import System.Environment (getArgs)
import qualified Data.ByteString.Char8       as BS8
import           PlutusTx.Builtins.Internal  (BuiltinByteString (..))
import           Plutus.V1.Ledger.Value      (TokenName (..))

import           Data.Maybe                  (fromJust)

import           Cardano.Api                 as API

main :: IO ()
main = do
    [tn'] <- getArgs
    let tn = fromString tn'
    writeFile ("tn") (unsafeTokenNameToHex tn)

unsafeTokenNameToHex :: TokenName -> String
unsafeTokenNameToHex = BS8.unpack . serialiseToRawBytesHex . fromJust . deserialiseFromRawBytes AsAssetName . getByteString . unTokenName
  where
    getByteString (BuiltinByteString bs) = bs

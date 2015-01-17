{-# LANGUAGE ViewPatterns, TupleSections, RecordWildCards, ScopedTypeVariables #-}

module Output.Names(writeNames, searchNames) where

import Language.Haskell.Exts
import Control.Applicative
import System.IO.Extra
import System.FilePath
import Data.List.Extra
import qualified Data.ByteString.Char8 as BS

import Input.Type
import General.Util


writeNames :: Database -> [(Maybe Id, Items)] -> IO ()
writeNames (Database file) xs = writeFileBinary (file <.> "names") $ unlines
    [show i ++ " " ++ name | (Just i, x) <- xs, name <- toName x]

toName :: Items -> [String]
toName (IKeyword x) = [x]
toName (IPackage x) = [x]
toName (IModule x) = [last $ splitOn "." x]
toName (IDecl x) = map fromName $ case x of
    TypeDecl _ name _ _ -> [name]
    DataDecl _ _ _ name _ _ _ -> [name]
    GDataDecl _ _ _ name _ _ _ _ -> [name]
    TypeFamDecl _ name _ _ -> [name]
    DataFamDecl _ _ name _ _ -> [name]
    ClassDecl _ _ name _ _ _ -> [name]
    TypeSig _ names _ -> names
    _ -> []


searchNames :: Database -> [String] -> IO [Id]
searchNames (Database file) xs = do
    src <- BS.lines <$> BS.readFile (file <.> "names")
    xs <- return $ map BS.pack xs
    return [read $ BS.unpack $ head $ BS.words i | i <- src, all (`BS.isInfixOf` i) xs]


module Hoogle.DataBase.All
    (DataBase, showDataBase
    ,module Hoogle.DataBase.All
    ,module Hoogle.DataBase.Serialise
    ) where

import Data.Binary.Defer.Index
import Hoogle.TypeSig.All
import Hoogle.DataBase.Type
import Hoogle.Item.All
import Hoogle.Score.All
import Hoogle.DataBase.Serialise


createDataBase :: [DataBase] -> Input -> DataBase
createDataBase deps (facts,xs) = DataBase items
        (createNameSearch ys) (createTypeSearch as is ys)
        (createSuggest (map suggest deps) facts) as is
    where
        items = createItems xs
        ys = entriesItems items
        as = createAliases (map aliases deps) facts
        is = createInstances (map instances deps) facts


combineDataBase :: [DataBase] -> DataBase
combineDataBase dbs = DataBase items_
        (createNameSearch ys) (createTypeSearch as is ys)
        ss as is
    where
        items_ = mergeItems $ map items dbs
        ys = entriesItems items_
        ss = mergeSuggest $ map suggest dbs
        as = mergeAliases $ map aliases dbs
        is = mergeInstances $ map instances dbs


searchName :: DataBase -> String -> [(Link Entry,EntryView,Score)]
searchName db = searchNameSearch (nameSearch db)


searchType :: DataBase -> TypeSig -> [(Link Entry,[EntryView],Score)]
-- although aliases and instances are given, they are usually not used
searchType db = searchTypeSearch (aliases db) (instances db) (typeSearch db)


suggestion :: [DataBase] -> TypeSig -> Maybe (Either String TypeSig)
suggestion db = askSuggest (map suggest db)


completions :: DataBase -> String -> [String]
completions db = completionsNameSearch (nameSearch db)

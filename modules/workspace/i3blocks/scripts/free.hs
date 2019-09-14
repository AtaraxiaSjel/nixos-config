import System.Exit

main :: IO ()
main = do
  freeMemory <- read
                <$> (!!1) <$> words
                <$> (!!2) <$> lines
                <$> readFile "/proc/meminfo"
  putStr $ (take 5 $ show $ freeMemory / ‭1048576‬) ++ "GiB"
  exitWith $ if freeMemory > 500000 then ExitSuccess else ExitFailure 33

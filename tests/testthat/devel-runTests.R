
## OPTIONS ----

  # Suppress warnings from calls to setupProject, simInit, and spades
  options("spades.test.suppressWarnings" = TRUE)
  
  # Set custom directory paths
  ## Speed up tests by allowing inputs, cache, and R packages to persist between runs
  options("spades.test.paths.inputs"   = NULL) # inputPath
  options("spades.test.paths.cache"    = NULL) # cachePath
  options("spades.test.paths.packages" = NULL) # packagePath

  # Test recreating the Python virtual environment
  ## WARNING: this will slow down testing, avoid unless Python is having issues
  Sys.setenv(RETICULATE_VIRTUALENV_ROOT = file.path(tempdir(), "virtualenvs"))


## RUN ALL TESTS ----

  # Run all tests
  testthat::test_dir("tests/testthat")

  # Run all tests with different reporters
  testthat::test_dir("tests/testthat", reporter = testthat::LocationReporter)
  testthat::test_dir("tests/testthat", reporter = testthat::SummaryReporter)


## RUN INDIVIDUAL TESTS ----
  
  ## Run RIA-small: no disturbances
  testthat::test_file("tests/testthat/test-RIA-small_disturbanceFree.R")
  
  ## Run RIA-small: FRI
  testthat::test_file("tests/testthat/test-RIA-small_FRI.R")
  
  ## Run RIA-small: harvest1
  testthat::test_file("tests/testthat/test-RIA-small_harvest1.R")
  
  ## Run RIA-small: harvest2
  testthat::test_file("tests/testthat/test-RIA-small_harvest2.R")
  
  ## Run RIA-small: presentDay
  testthat::test_file("tests/testthat/test-RIA-small_presentDay.R")
  
  
  
  
  


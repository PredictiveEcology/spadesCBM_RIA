
if (!testthat::is_testing()){
  suppressPackageStartupMessages(library(testthat))
  testthat::source_test_helpers(env = globalenv())
}

# Source work in progress SpaDES module testing functions
suppressPackageStartupMessages(library(SpaDES.core))
tempScript <- tempfile(fileext = ".R")
download.file(
  "https://raw.githubusercontent.com/suz-estella/SpaDES.core/refs/heads/suz-testthat/R/testthat.R",
  tempScript, quiet = TRUE)
source(tempScript)

# Set up testing global options
SpaDEStestSetGlobalOptions()

# Set up testing directories
spadesTestPaths <- SpaDEStestSetUpDirectories(
  modulePath  = "modules",
  moduleRepos = getOption("spades.test.modules"),
  require     = "googledrive"
)

## Store cache in RProject
if (!testthat::is_testing()) spadesTestPaths$temp$cache <- file.path(spadesTestPaths$RProj, "tests/cache")

# Recreate the Python virtual environment location
if (getOption("spades.test.virtualEnv", default = FALSE)){
  dir.create(file.path(spadesTestPaths$temp$root, "virtualenvs"))
  withr::local_envvar(
    list(RETICULATE_VIRTUALENV_ROOT = file.path(spadesTestPaths$temp$root, "virtualenvs")),
    .local_envir = if (testthat::is_testing()) testthat::teardown_env() else parent.frame())
}


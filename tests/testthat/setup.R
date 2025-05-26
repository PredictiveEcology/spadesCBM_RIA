
if (!testthat::is_testing()){
  suppressPackageStartupMessages(library(testthat))
  testthat::source_test_helpers(env = globalenv())
}

# 2025-05: Install latest quickPlot from Github required by LandR
## Otherwise SpaDES.core will install and load an older version from CRAN first
Require::Install("PredictiveEcology/quickPlot@development (>= 1.0.2.9001)")

# 2025-05 temporary: set Github repo branch to 'development' instead of presentDay'
if (Sys.getenv("BRANCH_NAME") == "presentDay") Sys.setenv(BRANCH_NAME = "development")

# Source work in progress SpaDES module testing functions
suppressPackageStartupMessages(library(SpaDES.core))
tempScript <- tempfile(fileext = ".R")
download.file(
  "https://raw.githubusercontent.com/suz-estella/SpaDES.core/refs/heads/suz-testthat/R/testthat.R",
  tempScript, quiet = TRUE)
source(tempScript)

# Set up testing directories and global options
SpaDEStestSetGlobalOptions()
spadesTestPaths <- SpaDEStestSetUpDirectories(modulePath = NA)

# Install required packages
withr::with_options(c(timeout = 600), Require::Install(
  c("SpaDES.project", "googledrive"),
  repos = unique(c("predictiveecology.r-universe.dev", getOption("repos")))
))


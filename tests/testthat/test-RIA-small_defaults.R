
if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("RIA-small", {

  ## Run simInit and spades ----
  
  # Set up project
  projectName <- "RIA-small"
  times       <- list(start = 2020, end = 2025)
  
  simInitInput <- SpaDEStestMuffleOutput(

    SpaDES.project::setupProject(
      
      times = times,

      modules = c(
        paste0("PredictiveEcology/CBM_defaults@",        Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep_RIA@",    Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep@",        Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_vol2biomass_RIA@", Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_core@",            Sys.getenv("BRANCH_NAME", "development"))
      ),
      paths   = list(
        projectPath = spadesTestPaths$projectPath,
        modulePath  = spadesTestPaths$modulePath,
        packagePath = spadesTestPaths$packagePath,
        inputPath   = spadesTestPaths$inputPath,
        cachePath   = spadesTestPaths$cachePath,
        outputPath  = file.path(spadesTestPaths$temp$outputs, projectName)
      ),

      # Set packages required for project set up
      require = "terra",
      
      # Set study area
      masterRaster = terra::rast(
        crs  = file.path(spadesTestPaths$testdata, "masterRasterCRS.prj"),
        res  = 250,
        vals = 1L,
        xmin = -1653000,
        xmax = -1553000,
        ymin =  7765000,
        ymax =  7865000
      )
    )
  )

  # Run simInit
  simTestInit <- SpaDEStestMuffleOutput(
    SpaDES.core::simInit2(simInitInput)
  )

  expect_s4_class(simTestInit, "simList")

  # Run spades
  simTest <- SpaDEStestMuffleOutput(
    SpaDES.core::spades(simTestInit)
  )

  expect_s4_class(simTest, "simList")


  ## Check outputs ----
  
  expect_true(!is.null(simTest$emissionsProducts))

})




if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("RIA-small - presentDay", {

  ## Run simInit and spades ----
  
  # Set up project
  projectName <- "4_presentDay"
  times       <- list(start = 2015, end = 2015) # Time span: 1985 - 2015
  
  simInitInput <- SpaDEStestMuffleOutput(

    SpaDES.project::setupProject(
      
      times = times,

      modules = c(
        paste0("PredictiveEcology/CBM_defaults@",        Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep_RIA@",    Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_dataPrep@",        Sys.getenv("BRANCH_NAME", "development")),
        paste0("PredictiveEcology/CBM_vol2biomass@", Sys.getenv("BRANCH_NAME", "development")),
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
      require = c("terra", "reproducible"),
      
      # Set study area
      masterRaster = terra::rast(
        crs  = file.path(spadesTestPaths$testdata, "masterRasterCRS.prj"),
        res  = 250,
        vals = 1L,
        xmin = -1653000,
        xmax = -1553000,
        ymin =  7765000,
        ymax =  7865000
      ),
      
      # Set age data year
      ageDataYear = 2015,

      # Set disturbances
      disturbanceMeta = data.table(
        eventID  = c(1, 2),
        name     = c("Wildfire", "Clearcut harvesting without salvage"),
        priority = c(1, 2)
      ),
      disturbanceRasters = list(
        `1` = reproducible::prepInputs(
          destinationPath = paths$inputPath,
          url             = "https://drive.google.com/file/d/1kxCL-i311yd3cS7QDQ2GwHHtyQFiiXoo",
          archive         = "historicalFire_1985-2015.zip",
          targetFile      = "historicalFire_1985-2015.tif",
          fun             = terra::rast
        ) |> setNames(1985:2015),
        `2` = reproducible::prepInputs(
          destinationPath = paths$inputPath,
          url             = "https://drive.google.com/file/d/1m7mjcx5Sz--RB7x4N3cPYpGkfmxX8KPB",
          archive         = "historicalHarvest_1985-2015.zip",
          targetFile      = "historicalHarvest_1985-2015.tif",
          fun             = terra::rast
        ) |> setNames(1985:2015)
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



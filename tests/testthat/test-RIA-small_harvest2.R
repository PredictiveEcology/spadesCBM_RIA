
if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("RIA-small - harvest2", {
  
  ## Run simInit and spades ----
  
  # Set up project
  projectName <- "3-2_harvest2"
  times       <- list(start = 2020, end = 2020) # Time span: 2020 - 2099
  
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
      require = c("terra", "reproducible"),
      
      # Set study area
      masterRaster = terra::rast(
        crs  = file.path(spadesTestPaths$testdata, "masterRasterCRS.prj"),
        vals = 1L,
        res  = 250,
        ext  = c(xmin = -1653000, xmax = -1553000, ymin = 7765000, ymax = 7865000)
      ),
      
      # Set disturbances
      disturbanceMeta = data.table(
        eventID  = c(1, 2),
        name     = c("Wildfire", "Clearcut harvesting without salvage"),
        priority = c(1, 2)
      ),
      disturbanceRasters = {
        
        tsas <- c(16, 40)
        
        reproducible::prepInputs(
          destinationPath = file.path(paths$inputPath, "harvest2"),
          url        = "https://drive.google.com/file/d/1PiDpeYGZJfKUPvMGlWvXkEfuThX-lD5r",
          targetFile = "tif_scenrio-carbon-less_20210622.tar.gz",
          fun       = NA)
        
        list(
          `1` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
            file.path(paths$inputPath, "harvest2", "tif", paste0("tsa", tsas), paste0("projected_fire_",    year, ".tif"))
          }),
          `2` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
            file.path(paths$inputPath, "harvest2", "tif", paste0("tsa", tsas), paste0("projected_harvest_", year, ".tif"))
          })
        )
      }
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




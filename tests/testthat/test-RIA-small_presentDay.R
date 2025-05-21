
if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("RIA-small presentDay", {

  ## Run simInit and spades ----

  # Set times
  times <- list(start = 1985, end = 2015)

  # Set project path
  projectPath <- file.path(spadesTestPaths$temp$projects, "RIA-small_presentDay")
  dir.create(projectPath)
  withr::local_dir(projectPath)
  
  # Set master raster CRS
  masterRasterCRS <- terra::crs(
    paste(readLines(file.path(spadesTestPaths$testdata, "masterRasterCRS.prj")), collapse = "\n"))
  
  # Set Github repo branch
  if (!nzchar(Sys.getenv("BRANCH_NAME"))) withr::local_envvar(BRANCH_NAME = "development")

  # Set up project
  simInitInput <- SpaDEStestMuffleOutput(

    SpaDES.project::setupProject(

      modules = c(
        paste0("PredictiveEcology/CBM_defaults@",        Sys.getenv("BRANCH_NAME")),
        paste0("PredictiveEcology/CBM_dataPrep_RIA@",    "presentDay"), # temporary
        paste0("PredictiveEcology/CBM_vol2biomass_RIA@", Sys.getenv("BRANCH_NAME")),
        paste0("PredictiveEcology/CBM_core@",            Sys.getenv("BRANCH_NAME"))
      ),
      
      times   = times,
      paths   = list(
        projectPath = projectPath,
        modulePath  = spadesTestPaths$modulePath,
        packagePath = spadesTestPaths$packagePath,
        inputPath   = spadesTestPaths$inputPath,
        cachePath   = spadesTestPaths$cachePath,
        outputPath  = file.path(projectPath, "outputs")
      ),

      # Set packages required for project set up
      require = c("terra", "reproducible"),
      
      # Set study area
      masterRaster = terra::rast(
        vals = 1L,
        res  = 250,
        ext  = c(xmin = -1653000, xmax = -1553000, ymin = 7765000, ymax = 7865000),
        crs  = masterRasterCRS
      ),

      # Set disturbances
      disturbanceMeta = data.table(
        eventID = c(1, 2),
        name    = c("Wildfire", "Clearcut harvesting without salvage")
      ),
      disturbanceRasters = list(
        `1` = reproducible::prepInputs(
          destinationPath = spadesTestPaths$inputPath,
          url             = "https://drive.google.com/file/d/1kxCL-i311yd3cS7QDQ2GwHHtyQFiiXoo",
          archive         = "historicalFire_1985-2015.zip",
          targetFile      = "historicalFire_1985-2015.tif",
          fun             = terra::rast
        ) |> setNames(1985:2015),
        `2` = reproducible::prepInputs(
          destinationPath = spadesTestPaths$inputPath,
          url             = "https://drive.google.com/file/d/1m7mjcx5Sz--RB7x4N3cPYpGkfmxX8KPB",
          archive         = "historicalHarvest_1985-2015.zip",
          targetFile      = "historicalHarvest_1985-2015.tif",
          fun             = terra::rast
        ) |> setNames(1985:2015)
      ),
      
      # Set outputs
      outputs = as.data.frame(expand.grid(
        objectName = c("cbmPools", "NPP"),
        saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
      ))
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
  
  expect_true(!is.null(simTest$spinupResult))
  
  expect_true(!is.null(simTest$cbmPools))
  
  expect_true(!is.null(simTest$NPP))
  
  expect_true(!is.null(simTest$emissionsProducts))

})



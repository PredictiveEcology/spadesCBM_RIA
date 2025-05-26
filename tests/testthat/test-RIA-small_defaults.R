
if (!testthat::is_testing()) source(testthat::test_path("setup.R"))

test_that("RIA-small", {

  ## Run simInit and spades ----

  # Set times
  times <- list(start = 2020, end = 2099)

  # Set project path
  projectPath <- file.path(spadesTestPaths$temp$projects, "RIA-small")
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



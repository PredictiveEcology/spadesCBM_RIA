projectPath <- "~/GitHub/spadesCBM_RIA"
repos <- unique(c("predictiveecology.r-universe.dev", getOption("repos")))
install.packages("SpaDES.project",
                 repos = repos)

times <- list(start = 2015, end = 2015) ##TODO: This is from the SK runs, set times needed. 

out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  paths = list(projectPath = projectPath),
  
  options = options(
    repos = c(repos = repos),
    Require.cloneFrom = Sys.getenv("R_LIBS_USER"),
    reproducible.destinationPath = "inputs",
    ## These are for speed
    reproducible.useMemoise = TRUE,
    # Require.offlineMode = TRUE,
    spades.moduleCodeChecks = FALSE
  ),
  modules =  c("PredictiveEcology/CBM_defaults@development",
               "PredictiveEcology/CBM_dataPrep_RIA@presentDay",
               "PredictiveEcology/CBM_vol2biomass_RIA@development",
               "PredictiveEcology/CBM_core@development"),
  times = times,
  require = c("SpaDES.core", "reticulate",
              "PredictiveEcology/libcbmr", "data.table", "googledrive"),
  
  params = list(
    CBM_defaults = list(
      .useCache = TRUE
    ),
    CBM_dataPrep_RIA = list(
      .useCache = TRUE
    ),
    CBM_vol2biomass_RIA = list(
      .useCache = TRUE
    )
  ),
  functions = "PredictiveEcology/CBM_core@training/R/ReticulateFindPython.R",
  
  ret = {
    reticulate::virtualenv_create(
      "r-spadesCBM",
      python = if (!reticulate::virtualenv_exists("r-spadesCBM")){
        ReticulateFindPython(
          version        = ">=3.9,<=3.12.7",
          versionInstall = "3.10:latest",
          pyenvRoot      = tools::R_user_dir("r-spadesCBM")
        )
      },
      packages = c(
        "numpy<2",
        "pandas>=1.1.5",
        "scipy",
        "numexpr>=2.8.7",
        "numba",
        "pyyaml",
        "mock",
        "openpyxl",
        "libcbm"
      )
    )
    reticulate::use_virtualenv("r-spadesCBM")
  },
  
  #### begin manually passed inputs #########################################

##TODO: include any manual inputs here
masterRasterCRS <- terra::crs(
  paste(readLines(file.path("~/GitHub/spadesCBM_RIA/inputs/masterRasterCRS.prj")), collapse = "\n")),

masterRaster = terra::rast(
  vals = 1L,
  res  = 250,
  ext  = c(xmin = -1653000, xmax = -1553000, ymin = 7765000, ymax = 7865000),
  crs  = masterRasterCRS
),
  
  
  outputs = as.data.frame(expand.grid(objectName = c("cbmPools", "NPP"),
                                      saveTime = sort(c(times$start,
                                                        times$start +
                                                          c(1:(times$end - times$start))
                                      )))),
  
)

# Run
simRIA <- SpaDES.core::simInitAndSpades2(out)

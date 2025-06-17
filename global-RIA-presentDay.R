
## PROJECT DESCRIPTION ##
# STUDY AREA: RIA
# TIME FRAME: 1985 - 2015
# DISTURBANCES: 
# Landsat-derived annual fire and harvest layers as described in: 
# Hermosilla, T., M.A. Wulder, J.C. White, N.C. Coops, G.W. Hobart, L.B. Campbell, (2016).
# Mass data processing of time series Landsat imagery: pixels to data products for forest monitoring.
# International Journal of Digital Earth. 9(11), 1035-1054.

# Set project path
projectPath <- "~/GitHub/spadesCBM_RIA"

# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set simulation time span
times <- list(start = 1985, end = 2015)

# Set up project
out <- SpaDES.project::setupProject(
  
  Restart = getOption("SpaDES.project.Restart", TRUE),
  useGit = "PredictiveEcology", # Clone the project repo from Github
  
  times = times,
  
  modules = c("PredictiveEcology/CBM_defaults@development",
              "PredictiveEcology/CBM_dataPrep_RIA@development",
              "PredictiveEcology/CBM_dataPrep@development",
              "PredictiveEcology/CBM_vol2biomass_RIA@development",
              "PredictiveEcology/CBM_core@development"),
  overwrite = TRUE, # Overwrite modules with latest updates
  
  paths = list(
    projectPath = projectPath,
    outputPath  = file.path(projectPath, "outputs", "RIA-presentDay"),
    modulePath  = file.path(projectPath, "modules"),
    packagePath = file.path(projectPath, "packages"),
    inputPath   = file.path(projectPath, "inputs"),
    cachePath   = file.path(projectPath, "cache")
  ),
  
  # Set options and parameters
  options = list(
    Require.cloneFrom       = Sys.getenv("R_LIBS_USER"),
    reproducible.useMemoise = TRUE,
    spades.moduleCodeChecks = FALSE
  ),
  params = list(
    CBM_defaults        = list(.useCache = TRUE),
    CBM_dataPrep_RIA    = list(.useCache = TRUE),
    CBM_dataPrep        = list(.useCache = c("inputObjects", "Init")),
    CBM_vol2biomass_RIA = list(.useCache = TRUE),
    CBM_core            = list(.useCache = TRUE)
  ),
  
  # Set packages required for project set up
  require = c("googledrive", "reproducible", "terra"),
  
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
      destinationPath = file.path(projectPath, "inputs"),
      url             = "https://drive.google.com/file/d/1kxCL-i311yd3cS7QDQ2GwHHtyQFiiXoo",
      archive         = "historicalFire_1985-2015.zip",
      targetFile      = "historicalFire_1985-2015.tif",
      fun             = terra::rast
    ) |> setNames(1985:2015),
    `2` = reproducible::prepInputs(
      destinationPath = file.path(projectPath, "inputs"),
      url             = "https://drive.google.com/file/d/1m7mjcx5Sz--RB7x4N3cPYpGkfmxX8KPB",
      archive         = "historicalHarvest_1985-2015.zip",
      targetFile      = "historicalHarvest_1985-2015.tif",
      fun             = terra::rast
    ) |> setNames(1985:2015)
  ),
  
  # Set outputs
  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime   = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




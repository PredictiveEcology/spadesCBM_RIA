
## PROJECT DESCRIPTION ##
# STUDY AREA: RIA
# TIME FRAME: 2020 - 2099
# DISTURBANCES: 
# TODO: describe

# Set project path
projectPath <- "~/GitHub/spadesCBM_RIA"

# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set simulation time span
times <- list(start = 2020, end = 2099)

# Set up project
out <- SpaDES.project::setupProject(
  
  Restart = getOption("SpaDES.project.Restart", TRUE),
  useGit = "PredictiveEcology", # Clone the project repo from Github
  
  times = times,
  
  modules = c("PredictiveEcology/CBM_defaults@development",
              "PredictiveEcology/CBM_dataPrep_RIA@development",
              "PredictiveEcology/CBM_dataPrep@development",
              "PredictiveEcology/CBM_vol2biomass@development",
              "PredictiveEcology/CBM_core@development"),
  overwrite = TRUE, # Overwrite modules with latest updates
  
  paths = list(
    projectPath = projectPath,
    outputPath  = file.path(projectPath, "outputs", "RIA-harvest1"),
    modulePath  = file.path(projectPath, "modules"),
    packagePath = file.path(projectPath, "packages"),
    inputPath   = file.path(projectPath, "inputs"),
    cachePath   = file.path(projectPath, "cache")
  ),
  
  # Set options and parameters
  options = list(
    Require.cloneFrom       = Sys.getenv("R_LIBS_USER"),
    reproducible.useMemoise = FALSE,
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
  require = c("googledrive", "reproducible"),
  
  # Set disturbances
  disturbanceMeta = data.table(
    eventID  = c(1, 2),
    name     = c("Wildfire", "Clearcut harvesting without salvage"),
    priority = c(1, 2)
  ),
  disturbanceRasters = {
    
    reproducible::prepInputs(
      destinationPath = file.path(paths$inputPath, "harvest1"),
      url        = "https://drive.google.com/file/d/1JpdB9CKpHga55jBmOlATkVyemqbUjtv5",
      targetFile = "tif_scenrio-carbon-base_20210622.tar.gz",
      fun       = NA)
    tsaDirs <- list.files(file.path(paths$inputPath, "harvest1", "tif"), full = TRUE)
    
    list(
      `1` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
        file.path(tsaDirs, paste0("projected_fire_",    year, ".tif"))
      }),
      `2` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
        file.path(tsaDirs, paste0("projected_harvest_", year, ".tif"))
      })
    )
  }
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




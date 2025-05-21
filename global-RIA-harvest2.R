
## PROJECT DESCRIPTION ##
# STUDY AREA: RIA
# TIME FRAME: 2020 - 2099
# DISTURBANCES: 
# TODO

# Set project path
projectPath <- "~/GitHub/spadesCBM_RIA"

# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set simulation time span
times <- list(start = 2020, end = 2100)

# Set up project
out <- SpaDES.project::setupProject(
  
  Restart = getOption("SpaDES.project.Restart", TRUE),
  useGit = "PredictiveEcology", # Clone the project repo from Github
  
  paths = list(
    projectPath = projectPath,
    outputPath  = file.path(projectPath, "outputs", "RIA-harvest2"),
    modulePath  = file.path(projectPath, "modules"),
    packagePath = file.path(projectPath, "packages"),
    inputPath   = file.path(projectPath, "inputs"),
    cachePath   = file.path(projectPath, "cache")
  ),
  
  times = times,
  modules = c("PredictiveEcology/CBM_defaults@development",
              "PredictiveEcology/CBM_dataPrep_RIA@presentDay",
              "PredictiveEcology/CBM_vol2biomass_RIA@development",
              "PredictiveEcology/CBM_core@development"),
  overwrite = TRUE, # Overwrite modules with latest updates
  
  require = c("googledrive", "reproducible"),
  
  options = list(
    Require.cloneFrom       = Sys.getenv("R_LIBS_USER"),
    reproducible.useMemoise = TRUE,
    spades.moduleCodeChecks = FALSE
  ),
  params = list(
    CBM_defaults = list(
      .useCache = TRUE
    ),
    CBM_dataPrep_RIA = list(
      .useCache = c(".inputObjects", "Init")
    ),
    CBM_vol2biomass_RIA = list(
      .useCache = TRUE
    )
  ),
  
  # Set disturbances
  disturbanceMeta = data.table(
    eventID = c(1, 2),
    name    = c("Wildfire", "Clearcut harvesting without salvage")
  ),
  disturbanceRasters = {
    
    reproducible::prepInputs(
      destinationPath = file.path(projectPath, "inputs", "harvest2"),
      url        = "https://drive.google.com/file/d/1PiDpeYGZJfKUPvMGlWvXkEfuThX-lD5r",
      targetFile = "tif_scenrio-carbon-less_20210622.tar.gz",
      fun        = utils::untar
    )
    tsaDirs <- list.files(file.path(projectPath, "inputs", "harvest2", "tif"), full = TRUE)
    
    list(
      `1` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
        file.path(tsaDirs, paste0("projected_fire_",    year, ".tif"))
      }),
      `2` = lapply(setNames(times$start:times$end, times$start:times$end), function(year){
        file.path(tsaDirs, paste0("projected_harvest_", year, ".tif"))
      })
    )
  },
  
  # Set outputs
  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime   = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




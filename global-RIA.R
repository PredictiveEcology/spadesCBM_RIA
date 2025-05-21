
## PROJECT DESCRIPTION ##
# STUDY AREA: RIA
# TIME FRAME: 2020 - 2099
# DISTURBANCES: N/A

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
  
  paths = list(
    projectPath = projectPath,
    outputPath  = file.path(projectPath, "outputs", "RIA-noDisturbances"),
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
  
  # Set packages required for project set up
  require = "googledrive",
  
  # Set outputs
  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




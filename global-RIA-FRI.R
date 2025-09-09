
## PROJECT DESCRIPTION ##
# STUDY AREA: RIA
# TIME FRAME: 2020 - 2540
# DISTURBANCES: 
# TODO: describe (scfm)

# Set project path
projectPath <- "~/GitHub/spadesCBM_RIA"

# Install SpaDES.project
if (tryCatch(packageVersion("SpaDES.project") < "0.1.1", error = function(x) TRUE)){
  install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")
}

# Set simulation time span
times <- list(start = 2020, end = 2540)

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
    outputPath  = file.path(projectPath, "outputs", "RIA-FRI"),
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
  require = c("googledrive", "reproducible", "terra"),
  
  # Set disturbances
  disturbanceMeta = data.table(
    eventID  = c(1, 2),
    name     = c("Wildfire", "Clearcut harvesting without salvage"),
    priority = c(1, 2)
  ),
  disturbanceRasters = list(`1` = {
    
    distFRI <- reproducible::prepInputs(
      destinationPath = paths$inputPath,
      url        = "https://drive.google.com/file/d/1fJIPVMyDu66CopA-YP-xSdP2Zx1Ll_q8",
      targetFile = "annualFires525yrs.tif",
      fun        = terra::rast
    )
    names(distFRI) <- 2015:2540
    
    distFRI
  })
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




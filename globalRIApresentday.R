
# Set project path
projectPath <- "~/GitHub/spadesCBM_RIA"

# Install SpaDES.project
install.packages("SpaDES.project", repos = "predictiveecology.r-universe.dev")

# Set simulation time span
times <- list(start = 1985, end = 2015)

# Set up project
out <- SpaDES.project::setupProject(
  
  Restart = TRUE,
  useGit = "PredictiveEcology", # a developer sets and keeps this = TRUE
  
  paths = list(projectPath = projectPath),
  times = times,
  modules = c("PredictiveEcology/CBM_defaults@development",
              "PredictiveEcology/CBM_dataPrep_RIA@presentDay",
              "PredictiveEcology/CBM_vol2biomass_RIA@development",
              "PredictiveEcology/CBM_core@development"),
  overwrite = TRUE, # a user who wants to get latest modules sets this to TRUE
  
  options = options(
    Require.cloneFrom = Sys.getenv("R_LIBS_USER"),
    reproducible.destinationPath = "inputs",
    ## These are for speed
    reproducible.useMemoise = TRUE,
    # Require.offlineMode = TRUE,
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
  
  outputs = as.data.frame(expand.grid(
    objectName = c("cbmPools", "NPP"),
    saveTime = sort(c(times$start, times$start + c(1:(times$end - times$start))))
  ))
)

# Run simulation
simRIA <- SpaDES.core::simInitAndSpades2(out)




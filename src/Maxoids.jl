module Maxoids

include("graphfunctions.jl")
include("separation.jl")
include("examplegraphs.jl")
include("globalmarkov.jl")

include("secondary_fan.jl")
import .OscarInterop: weights_for_cones, secondary_fan

export weights_for_cones

export star_reachability
export star_separation
export starsep
export csep

end # module Maxoids

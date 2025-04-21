needsPackage "GraphicalModels";

G = digraph{{1,2},{1,3},{2,4},{3,4}};
CI = {{{1},{4},{3}}, {{1},{4},{2,3}}, {{2},{3},{1}}};
assert(set(CI) === set(globalMarkov(G) | {{{1},{4},{3}}}));

R = gaussianRing G;
A = gaussianParametrization R;
det(A_{0,2}^{3,2}) --> l_{1,2} or l_{2,4} must vanish.

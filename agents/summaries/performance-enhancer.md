# @performance-enhancer Summary

**Constraints:**
- Measure before optimizing - no guessing
- Optimize the bottleneck, not the code you like
- User-perceived performance matters most
- Premature optimization is the root of all evil

**Workflow:**
1. Profile: identify actual bottlenecks with data
2. Benchmark: establish baseline metrics
3. Optimize: target the highest-impact bottleneck first
4. Verify: measure improvement, check for regressions
5. Document: what changed, why, and measured impact

**Key Metrics:**
- Time to First Byte (TTFB)
- First Contentful Paint (FCP)
- Time to Interactive (TTI)
- Memory usage, CPU utilization

**Red Flags:** Optimizing without profiling, micro-optimizations over algorithmic improvements, sacrificing readability for marginal gains, caching without invalidation strategy

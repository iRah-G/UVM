
## SystemVerilog Coverage & Covergroups Cheat Sheet

### Covergroup vs Coverpoint

Covergroup:
The container that defines when, what, and how to collect coverage.
Think of it as the “coverage structure” — it holds coverpoints, bins, crosses, and manages sampling.

Coverpoint:
The target within a covergroup — what you specifically want to measure or track.
It’s applied to a signal or expression, and it defines bins (ranges, values) to tally how often each is seen.

### 1. Covergroup Basics

```systemverilog
covergroup cg @(event);
    // coverpoints and bins inside
endgroup

cg my_cg = new();
my_cg.sample();   // Manual sampling
```
- `@(event)` optional: samples on event (like `posedge clk`)
- `.sample()` lets you sample manually

---

### 2. Coverpoints

```systemverilog
coverpoint signal_name;
coverpoint (expression);   // e.g., coverpoint (data[7:4])
```
- Monitors variables or expressions for coverage

---

### 3. Bins

```systemverilog
coverpoint signal {
    bins name1 = {[start:end]};
    bins name2 = {val1, val2, ...};
    bins all_bins[] = {[range]};     // automatic bins
    ignore_bins x = {values};        // exclude these from coverage
    illegal_bins y = {values};       // flag an error on these hits
}
```
- Track how often values or ranges are seen

---

### 4. Cross Coverage

```systemverilog
cross coverpoint1, coverpoint2;
```
- Measures all pairings/combinations

---

### 5. Example: Full Covergroup

```systemverilog
covergroup cg @(posedge clk);
    coverpoint addr {
        bins low  = {[0:3]};
        bins mid  = {[4:7]};
        bins high = {[8:15]};
    }
    coverpoint data;
    cross addr, data;
endgroup
```
- Three named bins for `addr`; cross coverage for `addr` & `data`

---

### 6. Useful Coverage Functions

```systemverilog
$coverage_show();    // prints coverage info
$coverage_save();    // saves coverage database
$coverage_get();     // gets coverage value
```

---

### 7. Coverage Filters

Sample only when a condition is true:
```systemverilog
covergroup cg @ (posedge clk iff enable);
```

---

### 8. Instantiation & Sampling

```systemverilog
cg my_cg = new();
my_cg.sample();   // call this to sample at any time
```
- Automatic: `@(event)`
- Manual:  `.sample()`

---

### 9. Custom Bin Example

Check if signal is even or odd:
```systemverilog
coverpoint sig {
    bins even = { [0:15] } iff (sig % 2 == 0);
    bins odd  = { [0:15] } iff (sig % 2 == 1);
}
```

---

### 10. Coverage Goal

- Confirm all bins and cross combinations are hit for high-quality verification.

---

#### Tips
- Use named bins for readability.
- Use cross coverage for combinations.
- Ignore/illegal bins for excluding or error checking.
- Pair with cover property in assertions to ensure triggers fired.

---

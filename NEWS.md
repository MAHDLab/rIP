---
title: "NEWS.md"
author: "rIP Authors and Contributors"
date: "5/27/2019"
output: html_document
---

# `rIP` 1.2.0

## Major Changes

With several contributions from Bob Rudis (hrbrmstr), we have substantially updated and streamlined the `rIP` package. Here are some highlights:

* Added discrete API endpoints for the three IP services so users can use this as a general purpose utility package as well as for the task-specific functionality currently provided. Each endpoint is tied to an environment variable for the secret info (API key or contact info). This is documented in each function.

* `aaa.R` contains an on-load computed package global `.RIP_UA` which is an `httr` user_agent object, given the best practice to use an identifiable user agent when making API calls so the service provider can track usage and also follow up with any issues they see.

* We recently published a complementary software paper in the _Journal of Open Source Software_. Please cite use of the `rIP` package accordingly: "Waggoner, Philip D., Ryan Kennedy, and Scott Clifford, (2019). Detecting Fraud in Online Surveys by Tracing, Scoring, and Visualizing IP Addresses. Journal of Open Source Software, 4(37), 1285, <https://doi.org/10.21105/joss.01285>."

## Minor Changes

* Bob Rudis added to `DESCRIPTION` as a contributor.

* Added `URL` and `BugReports` fields.

* Colored barplots via the `amerika` color palette generator package (<https://github.com/pdwaggoner/amerika>).

## How do I get `rIP `?

The package is released on CRAN and is developed and stored at the corresponding GitHub repository: <https://github.com/MAHDLab/rIP>. Questions or concerns? Please reach out to us directly via email or issue tickets on GitHub. Thanks and enjoy!
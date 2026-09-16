# Repository Guide

## Reading order

1. Read the root README for project scope and verification state.
2. Start with the [RV32I APB SoC](../RV32I_APB_Custom_SoC/README.md) for the main design artifact.
3. Review the [UART UVM project](../02_Serial_IPs_with_UVM/README.md) for the verification-focused artifact.
4. Consult the [evidence register](PORTFOLIO_EVIDENCE.md) before interpreting a numerical, verification, or hardware claim.

## Contribution and public-release rules

- Keep generated simulator databases, Vivado runs, bitstreams, temporary waveforms, and machine-local paths out of version control unless intentionally curated as evidence.
- For every new project, add a project README with: problem statement, architecture, source layout, test plan, observed result, reproduction steps, limitations, and next steps.
- Do not replace a verified result with a narrative claim. Link the log, report, waveform, test, or board capture that substantiates it.
- Do not publish third-party course material, vendor IP, credentials, or proprietary tool output without reviewing its license and contents.

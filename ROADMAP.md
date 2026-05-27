# Project Epic: Automated TIA Portal CI/CD & AI Code Review Pipeline (The "Nightly Watchdog")

## Executive Summary

This initiative transforms our Siemens TIA Portal infrastructure from a manual, isolated engineering environment into a modern software-development pipeline. By leveraging the local HTTP Model Context Protocol (MCP) gateway, we will deploy an autonomous "Watchdog" agent that runs on a nightly schedule. This agent will automatically sync our Multiuser projects, export all logic to standard Git version control, and utilize a local AI model to review code changes, enforce corporate engineering standards, and generate human-readable changelogs.

## Core Objectives & Business Value

- **Automated Traceability (No Vendor Lock-in):** Extracts proprietary Siemens SCL and XML blocks into standard, open-source Git repositories. IT and management can track plant changes without needing a STEP 7 license or TIA Portal installation.
- **Proactive Risk Mitigation:** Prevents "debug code" from making it to production. The AI instantly flags dangerous anomalies (e.g., temporary test timers, bypassed safety interlocks, or forced outputs) the same day they are written.
- **Automated Documentation:** Eliminates the burden of manual release notes. The AI translates raw SCL diffs into plain-English commit messages and changelogs.
- **Architectural Auditing:** Ensures all code adheres to team standards (e.g., enforcing `HandleErrorsWithinBlock = True`, verifying tag naming conventions, and tracking block version drift).

## Architecture & Tech Stack

- **The Engine:** `TiaMcpServer` (our custom asynchronous HTTP microservice).
- **The Source of Truth:** Siemens TIA Portal Multiuser Server / Project Server.
- **The Orchestrator:** A lightweight Python cron-job / agent running on a local server.
- **The Repository:** Standard enterprise Git (GitLab / GitHub).
- **The Analyst:** A secure, locally-routed LLM to analyze code diffs.

## The Execution Workflow (The Nightly Loop)

When the scheduler triggers the Watchdog at midnight, it executes the following sequence autonomously:

1. **Wake & Sync:** The agent connects to the TiaMcpServer API and issues commands to sequentially open the targeted Multiuser projects and synchronize the local sessions with the latest server changes.
2. **Deep Extraction:** Using the `GetSoftwareTree`, `ExportBlock`, and `ExportTagTable` MCP tools, the agent dumps the entirety of the project's SCL logic and IO tag mapping into a local workspace directory mapped to Git.
3. **Diff Detection:** The agent runs a standard `git diff`. If no files were altered that day, the project is marked clean, and the agent moves to the next project.
4. **AI Code Review:** If changes are detected, the raw SCL/XML diffs are fed to the AI model with a strict prompt framework:
   - Identify the functional intent of the changes.
   - Scan for corporate standard violations (e.g., missing comments, incorrect casing, legacy copy/paste).
   - Highlight critical safety risks (e.g., an `EventsTester` block overwriting global buffer slots).
5. **Commit & Alert:** The AI generates a structured commit message. The agent pushes the code to the Git server and, if critical flaws were detected, fires an alert (via Teams/Email) to the Lead Engineer detailing the exact lines of non-compliant code.

## Epic 2: "Docs-to-Code" Reconciliation (Integrating Au2mate Skills)

The existing `Au2mate Skills` repository contains Python parsers that today generate SCADA Excel sheets from FDS Word documents in an offline, batch fashion. With the live HTTP MCP gateway in place, those parsers stop being one-shot generators and become continuous reconciliation agents bridging documentation and live PLC code.

- **Live UDT Fetching:** Upgrade the existing `Setpoints txt` skill to bypass manual TIA Portal exports. The Python script will use the HTTP MCP bridge to dynamically fetch live UDT structures and Tag Tables directly from the active engineering session.
- **Continuous FDS Auditing:** Integrate `parse_fds.py` into the Nightly Watchdog. The Watchdog will parse the state machines and alarms from the Word documents and cross-reference them against the live PLC code extracted via MCP, automatically flagging "Silent Drift" (e.g., an alarm required by the FDS but missing in the PLC).
- **Direct SCADA Injection:** Phase out the intermediate `.xls` generation. Build new MCP "Write" tools allowing the AI to inject StatusTxt and AlarmTxt strings directly into the TIA Portal Text Lists based on the parsed FDS.

## Roadmap Prerequisites (What we need to build next)

To unlock this epic, the following minor features must be added to the current TiaMcpServer backlog:

- **Multiuser Support Extensions:** Implement a `SyncMultiuserProject` tool to safely pull the latest changes from the Siemens Project Server via Openness before extraction.
- **Workspace Lifecycle Management:** Add `OpenProject` and `CloseProject` MCP tools to ensure the server can cycle through multiple projects sequentially without encountering TIA Portal memory leaks or file locks.
- **Streaming Progress (SSE):** Complete the Server-Sent Events (SSE) pipe so the Python agent can monitor the progress of heavy block exports and handle timeouts gracefully.

---

*Note: The HTTP bridge was the plumbing. This Watchdog is the actual product. Instead of manually querying the AI to find legacy blocks or rogue test code, this system will find them automatically while the engineering team sleeps.*

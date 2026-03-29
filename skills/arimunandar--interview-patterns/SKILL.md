---
name: Interview Patterns
description: Best practices for gathering requirements using AskUserQuestion before taking action
version: 1.0.0
---

# Interview Patterns for iOS Development

A systematic approach to gathering requirements before implementing features, reviewing code, or performing analysis. Using the `AskUserQuestion` tool ensures you understand the user's needs before taking action.

## Why Interview First?

### Problems with Skipping Requirements Gathering

1. **Wasted effort** - Building the wrong thing
2. **Assumptions** - Guessing at requirements leads to rework
3. **Missing context** - Not understanding constraints or priorities
4. **User frustration** - Having to correct mid-implementation

### Benefits of Interview-First Approach

1. **Clarity** - Both you and the user agree on the goal
2. **Efficiency** - Build the right thing the first time
3. **Trust** - User feels heard and involved
4. **Better outcomes** - Tailored solutions vs. generic ones

## Using the AskUserQuestion Tool

### Tool Syntax

```
AskUserQuestion tool with:
- questions: Array of 1-4 questions
- Each question has:
  - question: The full question text
  - header: Short label (max 12 chars) for the chip/tag
  - options: 2-4 choices with label and description
  - multiSelect: true/false (allow multiple selections)
```

### Question Design Guidelines

**Good Questions:**
- Specific and actionable
- Provide meaningful choices
- Include descriptions that explain trade-offs
- Use multiSelect when choices aren't mutually exclusive

**Bad Questions:**
- Vague or open-ended
- Too many options (stick to 2-4)
- Missing context/descriptions
- Yes/No when more nuance is needed

## Interview Flow

### Standard Interview Pattern

```
1. Receive user request
2. Identify what information is needed
3. Use AskUserQuestion with relevant questions
4. Wait for user responses
5. Summarize understanding back to user
6. Proceed with action based on answers
```

### Example Flow

```
User: "Create a product detail screen"

Claude: [Uses AskUserQuestion]
- Question 1: What's the main purpose?
- Question 2: What components are needed?
- Question 3: Where does data come from?

User: [Selects answers]

Claude: "Got it! I'll create a product detail screen with:
- Image gallery, title, price, description
- Buy button with purchase flow
- Data from your REST API

[Shows ASCII preview]
[Then generates VIP+W code]"
```

## When to Skip the Interview

### Skip Interview If:

1. **User says "skip questions"** or "just do it"
2. **User provided all details** in their initial prompt
3. **Task is trivial** - Single file fix, typo, obvious bug
4. **User is explicit** - "Use exactly these specifications..."

### How to Detect Sufficient Information

Look for:
- Specific file/class names mentioned
- Clear acceptance criteria stated
- Technical approach already decided
- Constraints explicitly listed

## Question Templates by Task Type

### UI Creation Questions

```markdown
1. **Screen Purpose**
   - "What is the main purpose of this screen?"
   - Options: Display data, Form input, Navigation hub, Settings

2. **Key Components**
   - "What UI elements do you need?" (multiSelect)
   - Options: Text labels, Text fields, Buttons, Images, Lists/Tables

3. **Data Source**
   - "Where does the data come from?"
   - Options: API/Network, Local database, User input, Static content

4. **Navigation**
   - "How do users navigate from this screen?"
   - Options: Push to detail, Present modal, Tab switching, Back only
```

### Code Review Questions

```markdown
1. **Review Focus**
   - "What should I focus on?"
   - Options: Full review, Architecture only, Performance only, Security only

2. **Severity Threshold**
   - "What issues should I flag?"
   - Options: Blockers only, Blockers + warnings, Everything including minor

3. **Context**
   - "What type of code is this?"
   - Options: New feature, Bug fix, Refactoring, Legacy code
```

### Migration/Refactoring Questions

```markdown
1. **Scope**
   - "What do you want to migrate?"
   - Options: Single ViewController, Feature module, Entire app, Just analyze

2. **Current Pain Points**
   - "What problems are you experiencing?" (multiSelect)
   - Options: Bugs, Hard to test, Hard to change, Performance issues

3. **Testing Status**
   - "Do you have existing tests?"
   - Options: Yes - comprehensive, Yes - some, No tests, Not sure

4. **Timeline**
   - "How urgent is this?"
   - Options: Can take time, Medium urgency, Need it fast
```

### Performance/Memory Analysis Questions

```markdown
1. **Symptoms**
   - "What issues are you seeing?" (multiSelect)
   - Options: Slow scrolling, Slow launch, Memory warnings, UI freezes

2. **Target Area**
   - "Where should I focus?"
   - Options: Specific file/class, Entire feature, App-wide scan

3. **Success Metrics**
   - "What's your target?"
   - Options: 60fps scrolling, <2s launch, Reduce memory 50%, General improvement
```

### Security Audit Questions

```markdown
1. **Focus Area**
   - "What's the primary concern?"
   - Options: Data storage, Network security, Authentication, Full audit

2. **Sensitive Data**
   - "What data does the app handle?" (multiSelect)
   - Options: User credentials, Payment info, Personal health, Location

3. **Compliance**
   - "Any compliance requirements?"
   - Options: OWASP Mobile Top 10, HIPAA, PCI-DSS, General best practices
```

## Adapting Based on Answers

### Using Responses to Guide Action

```swift
// Based on user's interview answers:

if purpose == .displayData && dataSource == .api {
    // Generate VIP+W with API Worker
} else if purpose == .formInput && dataSource == .userInput {
    // Generate VIP+W with validation in Interactor
}

if reviewFocus == .securityOnly {
    // Run security-focused review
} else if reviewFocus == .performanceOnly {
    // Run performance-focused review
}
```

### Clarifying Follow-up Questions

If initial answers reveal ambiguity:

```
"You mentioned the data comes from multiple sources. Could you clarify:
- Which sources are primary vs. fallback?
- Should offline mode be supported?"
```

## Anti-Patterns

### Never Do These

1. **Ask then ignore** - Don't ask questions if you won't use the answers
2. **Too many questions** - Keep to 2-4 questions max per interview
3. **Redundant questions** - Don't ask what user already told you
4. **Blocking questions** - Don't halt for trivial details
5. **Leading questions** - Don't push toward your preferred solution

### Instead Do These

1. **Targeted questions** - Ask only what affects your approach
2. **Batch related questions** - Group related questions together
3. **Read the prompt first** - Extract info user already provided
4. **Provide good defaults** - First option should be recommended
5. **Neutral phrasing** - Let user choose without bias

## Integration with Agents

### Agent-Specific Interview Timing

| Agent | When to Interview |
|-------|-------------------|
| uikit-architect | Before creating any UI |
| legacy-migrator | Before analyzing or migrating |
| ios-code-reviewer | Before reviewing code |
| performance-optimizer | Before analyzing performance |
| memory-leak-detector | Before scanning for leaks |
| accessibility-auditor | Before auditing accessibility |
| ios-security-auditor | Before security audit |
| test-coverage-analyzer | Before analyzing coverage |
| appstore-reviewer | Before App Store review |

### Combining Interview with Action

```
1. Interview → Gather requirements
2. Summarize → Confirm understanding
3. Preview → Show plan/ASCII/outline
4. Confirm → Get user approval
5. Execute → Perform the action
```

## Summary

The interview-first approach ensures:

- **Right solution** - Built to actual requirements
- **User alignment** - Shared understanding of goals
- **Efficient work** - No rework from misunderstanding
- **Professional process** - Structured, repeatable methodology

Always use `AskUserQuestion` before significant actions unless the user has explicitly provided all needed information or requested to skip the interview.

# Svelte Coding Plugin for Claude Code

> shadcn-svelte component detection and documentation for building accessible, beautiful UIs in SvelteKit projects.

## Installation

```bash
claude plugin marketplace add rajnandan1/such-skills
claude plugin install ss-svelte-coding@such-skills
```

## Skills

### ss-shadcn-svelte

Detects whether your project is a SvelteKit app with shadcn-svelte installed, lists installed components, and provides access to full component documentation so the assistant uses the right components for the job.

**What it does:**

1. **Detects** SvelteKit + shadcn-svelte in your project
2. **Lists** already-installed components
3. **Provides** full component docs via the official [llms.txt](https://www.shadcn-svelte.com/llms.txt)
4. **Guides** component selection, installation, and usage

**Usage:**

```bash
# Detect project setup and list installed components
bash <skill-path>/scripts/detect.sh .
```

**Available components:**

| Category | Components |
|----------|-----------|
| **Layout** | Aspect Ratio, Collapsible, Resizable, Scroll Area, Separator, Sidebar |
| **Form & Input** | Button, Calendar, Checkbox, Combobox, Date Picker, Input, Input OTP, Label, Radio Group, Range Calendar, Select, Slider, Switch, Textarea, Toggle, Toggle Group |
| **Data Display** | Accordion, Avatar, Badge, Card, Carousel, Chart, Table, Data Table |
| **Feedback** | Alert, Alert Dialog, Progress, Skeleton, Sonner (Toast) |
| **Overlay** | Context Menu, Dialog, Drawer, Dropdown Menu, Hover Card, Menubar, Popover, Sheet, Tooltip |
| **Navigation** | Breadcrumb, Command, Pagination, Tabs |
| **Typography** | Typography |

**Adding components:**

```bash
# Add a single component
npx shadcn-svelte@latest add button

# Add multiple components
npx shadcn-svelte@latest add button card dialog
```

## Examples

Ask Claude naturally:

```
add a dialog to my page
```
```
I need a data table with sorting and filtering
```
```
create a form with email and password fields
```
```
add a sidebar navigation to my app
```
```
what shadcn-svelte components are installed in my project?
```

## License

MIT

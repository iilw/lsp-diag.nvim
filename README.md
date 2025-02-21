# nui-codeaction.nvim

A Neovim plugin based on nui.nvim that displays code actions in a floating window. With a clean layout and intuitive interactions, it helps developers quickly inspect and fix code issues.

## Features

- **Floating Window Display**: Utilizes nui. nvim to show code actions in a floating window, providing a clean and organized interface.


## Installation

### [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "iilw/nui-codeaction.nvim",
    event = "Buf",
    opts = {}
}
```

## Configuration

```lua
opts = {
    notify_silent = false,
	nui_options = {
		border = {
			style = "rounded",
			text = {
				top = "ACTIONS",
			},
		},
	},
}
```
### [nui_options](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup)

## Use

```lua
:NuiCodeactionShow
```

## Reference
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

Thanks to nui.nvim for providing powerful UI components.

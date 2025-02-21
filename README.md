# nui-codeaction.nvim

A Neovim plugin based on nui.nvim that displays code actions in a floating window. With a clean layout and intuitive interactions, it helps developers quickly inspect and fix code issues.

![Example git](https://private-user-images.githubusercontent.com/42507869/415485635-6da3d5d5-0b8f-468c-8176-3bc846bed8a8.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDAxMDkwMTksIm5iZiI6MTc0MDEwODcxOSwicGF0aCI6Ii80MjUwNzg2OS80MTU0ODU2MzUtNmRhM2Q1ZDUtMGI4Zi00NjhjLTgxNzYtM2JjODQ2YmVkOGE4LmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAyMjElMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMjIxVDAzMzE1OVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWU4ODRmYWU0ODYwNjRiNWUxZWFkMzljNjJiNTZmZjU5YWExYjEyOTE3NzkxYjgwYmFjZTQwMjI5YWY0ODFjYWYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.WIaHnIcszFeaLR3uWlN3AF1MriRty9u_knppOK4sKYA)

## Features

- **Floating Window Display**: Utilizes nui. nvim to show code actions in a floating window, providing a clean and organized interface.


## Installation

### [Lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "iilw/nui-codeaction.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim"
    },
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

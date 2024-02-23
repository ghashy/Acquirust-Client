<p align="center">
  <img src="https://github.com/ghashy/acqui/assets/109857267/406bb994-f5c4-4d87-918b-9571c2c98026?raw=true" height="128">
  <h1 align="center">acquisim client for macOS</h1>
</p>

This is `macOS` client for managing the [acquisim](https://github.com/ghashy/acquirust/tree/main/acquisim) instance. It enables easy execution of operations necessary for managing the bank simulator, including:

- Adding an account
- Deleting an account
- Opening credit
- Creating transactions

The client allows viewing a list of accounts with information on card numbers, transaction counts, and balances for each account. Additionally, it provides instant UI response when performing operations that alter the bank's state.

Moreover, it offers a real-time log stream from the Acquisim instance. In future updates, a transactions view will be implemented to display transaction graphs.

Real-time possibilities implemented using `web-sockets`.

## Instruction:

- Setup your [acquisim](https://github.com/ghashy/acquirust/tree/main/acquisim) instance.
- Run application, and open settings. Setup endpoint, username, and password.
- Press `update` button in the toolbar.

> Then `acqui` should connect immediately.

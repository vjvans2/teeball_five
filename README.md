# README

To setup the project run:
```bash
bundle exec rake project:setup
```

Start the Rails server
```bash
rails server
```

FAQ
I'm getting a "Could not find a JavaScript runtime" error because I'm on Windows instead of Mac
```bash
# you need to install nodeJs to your Ubuntu
sudo apt-get install nodejs
```

Run the cop
```bash
rubocop -A 
```

"I'm ready to test some things"
```bash
rake db:ts
```
Truncates the tables and then runs the seed command.

Navigate to <a>localhost:3000</a>

### Legal
This repository is owned by VanSlyke Ventures, LLC.

Initial development was created by Vincent VanSlyke(vjvans2) and
assigned to the company via IP Assignment dated 12/23/2025

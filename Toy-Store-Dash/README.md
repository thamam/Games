# 🎪 Toy Store Dash 🎪

An educational math game for kids (Ages 5-9) that teaches budgeting, addition, and mental arithmetic through fun gameplay!

## 🎮 Game Overview

**Toy Store Dash** is an interactive browser-based game where players manage a budget, shop for toys, and practice their math skills. The goal is to collect as many toys as possible without going broke!

## 🎯 Educational Objectives

This game teaches children:

1. **Estimation & Number Sense** - During shopping, kids estimate which toys they can afford
2. **Inequalities** - Understanding constraints (cart total + new item ≤ budget)
3. **Addition Skills** - Calculating the total cost of items in their cart
4. **Money Management** - Learning about budgets, change, and savings

## 🕹️ How to Play

### Game Flow

1. **💰 The Wallet** - Start with savings in your piggy bank ($100)
2. **🎫 The Budget** - Receive a random shopping budget for the round
3. **🛍️ Shopping Spree** - Drag toys to your cart within the time limit
   - You can only add toys if you can afford them
   - Drag toys back to the shelf if you change your mind
4. **🧮 Checkout** - Calculate the total cost of your items
5. **✨ Results** - Get rewarded for correct answers or penalized for mistakes

### Scoring System

- ✅ **Correct Answer**: You keep your change and add it back to your savings
- ❌ **Wrong Answer**: You lose the change (penalty for incorrect math)
- 🎁 **Either Way**: You keep the toys you bought!

## 🎚️ Difficulty Levels

### Level 1: Easy
- Toy prices: $1 - $5
- Budget: $10 - $20
- Timer: 30 seconds

### Level 2: Medium
- Toy prices: $5 - $15
- Budget: $20 - $50
- Timer: 25 seconds

### Level 3: Hard
- Toy prices: $10 - $30
- Budget: $50 - $100
- Timer: 20 seconds

## 🎨 Features

- **Drag-and-Drop Interface** - Intuitive for young players
- **Visual Budget Bar** - Shows how much of the budget is used (without numbers)
- **Countdown Timer** - Adds excitement and urgency
- **Trophy Room** - Collect and view all toys earned
- **Animated Feedback** - Colorful responses to actions
- **50+ Unique Toys** - Variety of emoji-based toys to collect

## 🚀 Getting Started

### Installation

No installation needed! Just open the game in any modern web browser.

### Running the Game

1. Open `index.html` in your web browser
2. Select your difficulty level
3. Click "Start Game!"
4. Have fun and learn!

### File Structure

```
Toy-Store-Dash/
├── index.html      # Main game structure
├── style.css       # All styling and animations
├── game.js         # Game logic and functionality
└── README.md       # This file
```

## 🎓 Technical Implementation

### Key Game Mechanics

#### Budget Constraint Logic
```javascript
if (cartTotal + newItem.price <= budget) {
    // Add item to cart
} else {
    // Reject item - too expensive!
}
```

#### Math Validation
```javascript
if (playerAnswer === actualTotal) {
    savings -= actualTotal;  // Pay exact cost
    savings += change;        // Get change back
} else {
    savings -= budget;        // Lose all budget (including change)
}
```

### Technologies Used

- **HTML5** - Structure and layout
- **CSS3** - Styling, animations, and responsive design
- **Vanilla JavaScript** - Game logic (no frameworks needed!)
- **Drag and Drop API** - Interactive gameplay

## 🎯 Gameplay Tips for Kids

1. **Look at the prices!** - Add up items in your head before dragging them
2. **Start with expensive items** - Get the big toys first, then fill with small items
3. **Use the timer wisely** - Don't rush, but don't wait too long!
4. **Practice your addition** - Getting the math right saves your money!
5. **Remove mistakes** - Drag items back to the shelf if you added too much

## 🏆 Game Over Conditions

The game ends when:
- Your total savings drops below the minimum budget for your difficulty level
- You can restart and try to beat your previous score!

## 📊 Stats Tracked

- Total Toys Collected
- Rounds Played
- Current Savings

## 🎨 Customization Ideas

Want to enhance the game? Here are some ideas:

- Add sound effects (cha-ching, error buzz, timer tick)
- Include subtraction challenges (calculating change)
- Add multiplication for advanced levels
- Create themed toy sets (sports, music, vehicles)
- Implement a high score leaderboard
- Add achievements and badges

## 🐛 Known Limitations

- No sound effects (currently uses visual feedback only)
- No data persistence (stats reset on page reload)
- Timer doesn't pause during drag operations

## 📱 Browser Compatibility

Tested and working on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 👨‍👩‍👧‍👦 For Parents & Teachers

This game is designed to make math practice fun and engaging. It reinforces:

- **Mental arithmetic** without calculators
- **Budgeting concepts** in a safe, consequence-free environment
- **Decision-making** under time pressure
- **Estimation skills** for real-world shopping

The game provides immediate feedback, helping children learn from mistakes while staying motivated through toy collection rewards.

## 📝 License

This game is free to use for educational purposes.

## 🤝 Contributing

Feel free to fork, modify, and enhance this game! Some ideas:
- Add new toy categories
- Create different game modes
- Implement saving/loading features
- Add more difficulty levels
- Create printable worksheets based on game rounds

## 🎉 Credits

Created as an educational tool to make math fun for kids!

Emoji icons provided by Unicode standard.

---

**Have fun playing and learning! 🎮📚✨**

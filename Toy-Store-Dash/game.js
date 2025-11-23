// ============================================
// GAME STATE
// ============================================

const GameState = {
    totalSavings: 100,
    roundBudget: 0,
    roundTimer: 30,
    cartItems: [],
    shelfItems: [],
    currentCartSum: 0,
    difficulty: 1,
    trophyRoom: [],
    roundsPlayed: 0,
    timerInterval: null,
    timeRemaining: 30
};

// Difficulty configurations
const DifficultyConfig = {
    1: { minPrice: 1, maxPrice: 5, minBudget: 10, maxBudget: 20, timer: 30 },
    2: { minPrice: 5, maxPrice: 15, minBudget: 20, maxBudget: 50, timer: 25 },
    3: { minPrice: 10, maxPrice: 30, minBudget: 50, maxBudget: 100, timer: 20 }
};

// Toy database with emojis
const ToyDatabase = [
    { icon: '🧸', name: 'Teddy Bear' },
    { icon: '🚗', name: 'Toy Car' },
    { icon: '⚽', name: 'Soccer Ball' },
    { icon: '🎮', name: 'Game Console' },
    { icon: '🪀', name: 'Yo-Yo' },
    { icon: '🎲', name: 'Dice' },
    { icon: '🎨', name: 'Paint Set' },
    { icon: '🎯', name: 'Dart Board' },
    { icon: '🪁', name: 'Kite' },
    { icon: '🎸', name: 'Guitar' },
    { icon: '🎹', name: 'Keyboard' },
    { icon: '🎺', name: 'Trumpet' },
    { icon: '🥁', name: 'Drums' },
    { icon: '🎪', name: 'Circus Tent' },
    { icon: '🎭', name: 'Theater Mask' },
    { icon: '🎬', name: 'Movie Clapper' },
    { icon: '🎤', name: 'Microphone' },
    { icon: '🎧', name: 'Headphones' },
    { icon: '🎩', name: 'Magic Hat' },
    { icon: '🎪', name: 'Balloon' },
    { icon: '🏀', name: 'Basketball' },
    { icon: '🏈', name: 'Football' },
    { icon: '⚾', name: 'Baseball' },
    { icon: '🎾', name: 'Tennis Ball' },
    { icon: '🏐', name: 'Volleyball' },
    { icon: '🏓', name: 'Ping Pong' },
    { icon: '🏒', name: 'Hockey Stick' },
    { icon: '🏹', name: 'Bow & Arrow' },
    { icon: '🎣', name: 'Fishing Rod' },
    { icon: '🛹', name: 'Skateboard' },
    { icon: '🛴', name: 'Scooter' },
    { icon: '🚲', name: 'Bicycle' },
    { icon: '🚂', name: 'Toy Train' },
    { icon: '✈️', name: 'Toy Plane' },
    { icon: '🚁', name: 'Helicopter' },
    { icon: '🚀', name: 'Rocket' },
    { icon: '🛸', name: 'UFO' },
    { icon: '🤖', name: 'Robot' },
    { icon: '🦖', name: 'Dinosaur' },
    { icon: '🦕', name: 'Brontosaurus' },
    { icon: '🐻', name: 'Bear Toy' },
    { icon: '🐼', name: 'Panda' },
    { icon: '🦁', name: 'Lion' },
    { icon: '🐯', name: 'Tiger' },
    { icon: '🦊', name: 'Fox' },
    { icon: '🐰', name: 'Bunny' },
    { icon: '🐶', name: 'Dog Toy' },
    { icon: '🐱', name: 'Cat Toy' },
    { icon: '🦄', name: 'Unicorn' },
    { icon: '🐉', name: 'Dragon' }
];

// ============================================
// UTILITY FUNCTIONS
// ============================================

function randomInteger(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function shuffleArray(array) {
    const newArray = [...array];
    for (let i = newArray.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
    }
    return newArray;
}

function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
}

function showFeedback(message, type = 'success') {
    const feedbackEl = document.getElementById('feedbackMessage');
    feedbackEl.textContent = message;
    feedbackEl.className = `feedback-message show ${type}`;

    setTimeout(() => {
        feedbackEl.classList.remove('show');
    }, 2000);
}

function updateSavingsDisplay() {
    document.getElementById('totalSavings').textContent = `$${GameState.totalSavings}`;

    // Update piggy bank color based on savings
    const piggyAmount = document.querySelector('.piggy-amount');
    if (GameState.totalSavings < 20) {
        piggyAmount.style.color = '#e74c3c';
    } else if (GameState.totalSavings < 50) {
        piggyAmount.style.color = '#f39c12';
    } else {
        piggyAmount.style.color = '#27ae60';
    }
}

// ============================================
// SCREEN: WELCOME
// ============================================

function initWelcomeScreen() {
    document.getElementById('startGameBtn').addEventListener('click', () => {
        GameState.difficulty = parseInt(document.getElementById('difficulty').value);
        startNewRound();
    });
}

// ============================================
// SCREEN: BUDGET REVEAL
// ============================================

function startNewRound() {
    // Check if player has enough money
    const config = DifficultyConfig[GameState.difficulty];
    if (GameState.totalSavings < config.minBudget) {
        showGameOver();
        return;
    }

    // Generate budget
    const config2 = DifficultyConfig[GameState.difficulty];
    GameState.roundBudget = randomInteger(config2.minBudget, config2.maxBudget);

    // Ensure budget doesn't exceed total savings
    if (GameState.roundBudget > GameState.totalSavings) {
        GameState.roundBudget = GameState.totalSavings;
    }

    // Reset cart
    GameState.cartItems = [];
    GameState.currentCartSum = 0;

    // Show budget reveal screen
    document.getElementById('budgetBill').querySelector('.bill-amount').textContent = `$${GameState.roundBudget}`;
    showScreen('budgetScreen');

    // Set up start shopping button
    document.getElementById('startShoppingBtn').onclick = () => {
        startShopping();
    };
}

// ============================================
// SCREEN: SHOPPING
// ============================================

function startShopping() {
    showScreen('shoppingScreen');

    // Generate shelf items
    generateShelfItems();

    // Set budget reminder
    document.getElementById('budgetReminder').textContent = `$${GameState.roundBudget}`;

    // Reset budget bar
    document.getElementById('budgetBar').style.width = '0%';
    document.getElementById('budgetBar').classList.remove('full');

    // Open curtains
    setTimeout(() => {
        document.getElementById('curtains').classList.add('open');
    }, 300);

    // Start timer
    const config = DifficultyConfig[GameState.difficulty];
    GameState.timeRemaining = config.timer;
    startTimer();

    // Reset cart display
    const cart = document.getElementById('cart');
    cart.innerHTML = '<div class="cart-empty" id="cartEmpty">Drag toys here!</div>';
    document.getElementById('checkoutBtn').style.display = 'none';

    // Set up drag and drop
    setupDragAndDrop();
}

function generateShelfItems() {
    const config = DifficultyConfig[GameState.difficulty];
    const toyCount = 12;

    // Shuffle toys and pick random ones
    const shuffledToys = shuffleArray(ToyDatabase);
    const selectedToys = shuffledToys.slice(0, toyCount);

    // Generate items with random prices
    GameState.shelfItems = selectedToys.map((toy, index) => {
        let price;

        // Ensure at least 3 items are affordable
        if (index < 3) {
            const maxAffordable = Math.floor(GameState.roundBudget / 2);
            price = randomInteger(config.minPrice, Math.min(maxAffordable, config.maxPrice));
        } else {
            price = randomInteger(config.minPrice, config.maxPrice);
        }

        return {
            id: `toy-${Date.now()}-${index}`,
            ...toy,
            price: price
        };
    });

    // Render shelf
    const shelf = document.getElementById('toyShelf');
    shelf.innerHTML = '';

    GameState.shelfItems.forEach(toy => {
        const toyEl = createToyElement(toy);
        shelf.appendChild(toyEl);
    });
}

function createToyElement(toy) {
    const div = document.createElement('div');
    div.className = 'toy-item';
    div.draggable = true;
    div.dataset.toyId = toy.id;
    div.innerHTML = `
        <div class="toy-icon">${toy.icon}</div>
        <div class="toy-name">${toy.name}</div>
        <div class="toy-price">$${toy.price}</div>
    `;
    return div;
}

function setupDragAndDrop() {
    const shelf = document.getElementById('toyShelf');
    const cart = document.getElementById('cart');

    // Drag events for toy items
    shelf.addEventListener('dragstart', (e) => {
        if (e.target.classList.contains('toy-item')) {
            e.target.classList.add('dragging');
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/html', e.target.dataset.toyId);
        }
    });

    shelf.addEventListener('dragend', (e) => {
        if (e.target.classList.contains('toy-item')) {
            e.target.classList.remove('dragging');
        }
    });

    // Drop events for cart
    cart.addEventListener('dragover', (e) => {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        cart.classList.add('drag-over');
    });

    cart.addEventListener('dragleave', (e) => {
        if (e.target === cart) {
            cart.classList.remove('drag-over');
        }
    });

    cart.addEventListener('drop', (e) => {
        e.preventDefault();
        cart.classList.remove('drag-over');

        const toyId = e.dataTransfer.getData('text/html');
        const toyEl = document.querySelector(`[data-toy-id="${toyId}"]`);

        if (toyEl && toyEl.parentElement.id === 'toyShelf') {
            onDropItemToCart(toyId);
        }
    });

    // Allow removing items from cart back to shelf
    cart.addEventListener('dragstart', (e) => {
        if (e.target.classList.contains('toy-item')) {
            e.target.classList.add('dragging');
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/html', e.target.dataset.toyId);
        }
    });

    cart.addEventListener('dragend', (e) => {
        if (e.target.classList.contains('toy-item')) {
            e.target.classList.remove('dragging');
        }
    });

    shelf.addEventListener('dragover', (e) => {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
    });

    shelf.addEventListener('drop', (e) => {
        e.preventDefault();

        const toyId = e.dataTransfer.getData('text/html');
        const toyEl = document.querySelector(`[data-toy-id="${toyId}"]`);

        if (toyEl && toyEl.parentElement.id === 'cart') {
            onDropItemToShelf(toyId);
        }
    });
}

function onDropItemToCart(toyId) {
    const toy = GameState.shelfItems.find(t => t.id === toyId);
    if (!toy) return;

    // Check constraint: can we afford this?
    const potentialSum = GameState.currentCartSum + toy.price;

    if (potentialSum <= GameState.roundBudget) {
        // SUCCESS - add to cart
        GameState.cartItems.push(toy);
        GameState.currentCartSum += toy.price;

        // Move element to cart
        const toyEl = document.querySelector(`[data-toy-id="${toyId}"]`);
        const cart = document.getElementById('cart');

        // Remove empty message
        const emptyMsg = document.getElementById('cartEmpty');
        if (emptyMsg) emptyMsg.remove();

        cart.appendChild(toyEl);

        // Update budget bar
        updateBudgetBar();

        // Show feedback
        showFeedback('Added to cart! 🛒', 'success');

        // Play sound (simulated with feedback)

    } else {
        // FAILURE - can't afford
        showFeedback("Too expensive! 💸", 'error');

        // Shake the item
        const toyEl = document.querySelector(`[data-toy-id="${toyId}"]`);
        toyEl.style.animation = 'shake 0.5s';
        setTimeout(() => {
            toyEl.style.animation = '';
        }, 500);
    }
}

function onDropItemToShelf(toyId) {
    const toyIndex = GameState.cartItems.findIndex(t => t.id === toyId);
    if (toyIndex === -1) return;

    const toy = GameState.cartItems[toyIndex];

    // Remove from cart
    GameState.cartItems.splice(toyIndex, 1);
    GameState.currentCartSum -= toy.price;

    // Move element back to shelf
    const toyEl = document.querySelector(`[data-toy-id="${toyId}"]`);
    const shelf = document.getElementById('toyShelf');
    shelf.appendChild(toyEl);

    // Update budget bar
    updateBudgetBar();

    // Check if cart is empty
    const cart = document.getElementById('cart');
    if (GameState.cartItems.length === 0) {
        cart.innerHTML = '<div class="cart-empty" id="cartEmpty">Drag toys here!</div>';
    }

    showFeedback('Removed from cart', 'success');
}

function updateBudgetBar() {
    const percentage = (GameState.currentCartSum / GameState.roundBudget) * 100;
    const bar = document.getElementById('budgetBar');
    bar.style.width = `${percentage}%`;

    if (percentage >= 100) {
        bar.classList.add('full');
    } else {
        bar.classList.remove('full');
    }
}

function startTimer() {
    const timerDisplay = document.getElementById('timerDisplay');
    timerDisplay.textContent = GameState.timeRemaining;
    timerDisplay.classList.remove('warning');

    if (GameState.timerInterval) {
        clearInterval(GameState.timerInterval);
    }

    GameState.timerInterval = setInterval(() => {
        GameState.timeRemaining--;
        timerDisplay.textContent = GameState.timeRemaining;

        if (GameState.timeRemaining <= 5) {
            timerDisplay.classList.add('warning');
        }

        if (GameState.timeRemaining <= 0) {
            clearInterval(GameState.timerInterval);
            endShopping();
        }
    }, 1000);
}

function endShopping() {
    clearInterval(GameState.timerInterval);

    // Check if cart is empty
    if (GameState.cartItems.length === 0) {
        showFeedback('No toys? Let\'s try again!', 'error');
        setTimeout(() => {
            startNewRound();
        }, 2000);
        return;
    }

    // Show checkout button
    document.getElementById('checkoutBtn').style.display = 'block';
    document.getElementById('checkoutBtn').onclick = () => {
        goToCheckout();
    };

    // Auto-proceed after 3 seconds
    setTimeout(() => {
        goToCheckout();
    }, 3000);
}

// ============================================
// SCREEN: CHECKOUT
// ============================================

function goToCheckout() {
    showScreen('checkoutScreen');

    // Build equation
    const equationContainer = document.getElementById('cartEquation');
    equationContainer.innerHTML = '';

    GameState.cartItems.forEach((toy, index) => {
        // Add toy
        const itemDiv = document.createElement('div');
        itemDiv.className = 'equation-item';
        itemDiv.innerHTML = `
            <div class="equation-icon">${toy.icon}</div>
            <div class="equation-price">$${toy.price}</div>
        `;
        equationContainer.appendChild(itemDiv);

        // Add plus sign (except for last item)
        if (index < GameState.cartItems.length - 1) {
            const plusDiv = document.createElement('div');
            plusDiv.className = 'equation-operator';
            plusDiv.textContent = '+';
            equationContainer.appendChild(plusDiv);
        }
    });

    // Add equals sign
    const equalsDiv = document.createElement('div');
    equalsDiv.className = 'equation-operator';
    equalsDiv.textContent = '=';
    equationContainer.appendChild(equalsDiv);

    // Add question mark
    const questionDiv = document.createElement('div');
    questionDiv.className = 'equation-operator';
    questionDiv.textContent = '?';
    equationContainer.appendChild(questionDiv);

    // Reset answer input
    document.getElementById('answerInput').value = '';
    document.getElementById('answerInput').focus();

    // Set up submit button
    document.getElementById('submitAnswerBtn').onclick = () => {
        submitAnswer();
    };

    // Allow Enter key to submit
    document.getElementById('answerInput').onkeypress = (e) => {
        if (e.key === 'Enter') {
            submitAnswer();
        }
    };
}

function submitAnswer() {
    const playerInput = parseInt(document.getElementById('answerInput').value);
    const actualCost = GameState.currentCartSum;
    const change = GameState.roundBudget - actualCost;

    if (isNaN(playerInput)) {
        showFeedback('Please enter a number!', 'error');
        return;
    }

    let isCorrect = playerInput === actualCost;

    // Show result screen
    showResultScreen(isCorrect, actualCost, change);

    // Update game state
    GameState.roundsPlayed++;

    if (isCorrect) {
        // Correct: Pay cost, keep change
        GameState.totalSavings -= actualCost;

        // Add toys to trophy room
        GameState.trophyRoom.push(...GameState.cartItems);

    } else {
        // Incorrect: Pay full budget (lose change)
        GameState.totalSavings -= GameState.roundBudget;

        // Still keep toys but lose the change
        GameState.trophyRoom.push(...GameState.cartItems);
    }

    updateSavingsDisplay();
}

// ============================================
// SCREEN: RESULT
// ============================================

function showResultScreen(isCorrect, actualCost, change) {
    showScreen('resultScreen');

    const resultIcon = document.getElementById('resultIcon');
    const resultTitle = document.getElementById('resultTitle');
    const resultDetails = document.getElementById('resultDetails');

    if (isCorrect) {
        resultIcon.textContent = '🎉';
        resultTitle.textContent = 'Correct! Great Job!';
        resultTitle.className = 'success';
        resultDetails.innerHTML = `
            <p>The correct total was <strong>$${actualCost}</strong>! ✅</p>
            <p>You got <strong>$${change}</strong> in change! 💰</p>
            <p>Your savings: <strong>$${GameState.totalSavings}</strong></p>
        `;
    } else {
        resultIcon.textContent = '😅';
        resultTitle.textContent = 'Oops! Not Quite Right!';
        resultTitle.className = 'error';
        resultDetails.innerHTML = `
            <p>The correct total was <strong>$${actualCost}</strong>.</p>
            <p>You lost <strong>$${change}</strong> in change! 😢</p>
            <p>But you still keep your toys! 🎁</p>
            <p>Your savings: <strong>$${GameState.totalSavings}</strong></p>
        `;
    }

    // Show toys won
    const toysWonContainer = document.getElementById('toysWon');
    toysWonContainer.innerHTML = '';
    GameState.cartItems.forEach(toy => {
        const toyEl = createToyElement(toy);
        toyEl.draggable = false;
        toysWonContainer.appendChild(toyEl);
    });

    // Set up buttons
    document.getElementById('nextRoundBtn').onclick = () => {
        startNewRound();
    };

    document.getElementById('viewTrophyBtn').onclick = () => {
        showTrophyRoom();
    };
}

// ============================================
// SCREEN: TROPHY ROOM
// ============================================

function showTrophyRoom() {
    showScreen('trophyScreen');

    // Update stats
    document.getElementById('totalToys').textContent = GameState.trophyRoom.length;
    document.getElementById('roundsPlayed').textContent = GameState.roundsPlayed;

    // Display trophies
    const trophyRoomContainer = document.getElementById('trophyRoom');
    trophyRoomContainer.innerHTML = '';

    if (GameState.trophyRoom.length === 0) {
        trophyRoomContainer.innerHTML = '<div class="no-toys">No toys yet! Start playing to collect toys! 🎁</div>';
    } else {
        GameState.trophyRoom.forEach(toy => {
            const toyEl = createToyElement(toy);
            toyEl.draggable = false;
            trophyRoomContainer.appendChild(toyEl);
        });
    }

    // Set up close button
    document.getElementById('closeTrophyBtn').onclick = () => {
        showScreen('resultScreen');
    };
}

// ============================================
// SCREEN: GAME OVER
// ============================================

function showGameOver() {
    showScreen('gameOverScreen');

    // Update final stats
    document.getElementById('finalToys').textContent = GameState.trophyRoom.length;
    document.getElementById('finalRounds').textContent = GameState.roundsPlayed;

    // Set up restart button
    document.getElementById('restartGameBtn').onclick = () => {
        resetGame();
    };
}

function resetGame() {
    GameState.totalSavings = 100;
    GameState.cartItems = [];
    GameState.shelfItems = [];
    GameState.currentCartSum = 0;
    GameState.trophyRoom = [];
    GameState.roundsPlayed = 0;

    updateSavingsDisplay();
    showScreen('welcomeScreen');
}

// ============================================
// DIFFICULTY CHANGE HANDLER
// ============================================

document.getElementById('difficulty').addEventListener('change', (e) => {
    GameState.difficulty = parseInt(e.target.value);
});

// ============================================
// INITIALIZATION
// ============================================

function initGame() {
    initWelcomeScreen();
    updateSavingsDisplay();
    showScreen('welcomeScreen');
}

// Start the game when page loads
document.addEventListener('DOMContentLoaded', initGame);

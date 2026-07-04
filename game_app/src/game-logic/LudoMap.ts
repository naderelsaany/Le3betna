export const LudoMap = {
  // SVG coordinates on a 1500x1500 canvas
  // Each square is 100x100. Center of a square is at x+50, y+50.
  // We'll define the exact (x, y) coordinates for the top-left of each slot, 
  // so we can render the board logic or position pieces at slot.x + 50, slot.y + 50.
  
  track: [
    // --- Green Start (Left arm, top row, moving right) ---
    {x: 100, y: 600}, {x: 200, y: 600}, {x: 300, y: 600}, {x: 400, y: 600}, {x: 500, y: 600},
    // Top arm, left col, moving up
    {x: 600, y: 500}, {x: 600, y: 400}, {x: 600, y: 300}, {x: 600, y: 200}, {x: 600, y: 100}, {x: 600, y: 0},
    {x: 700, y: 0}, // Top center
    {x: 800, y: 0}, // Top right
    // --- Red Start (Top arm, right col, moving down) ---
    {x: 800, y: 100}, {x: 800, y: 200}, {x: 800, y: 300}, {x: 800, y: 400}, {x: 800, y: 500},
    // Right arm, top row, moving right
    {x: 900, y: 600}, {x: 1000, y: 600}, {x: 1100, y: 600}, {x: 1200, y: 600}, {x: 1300, y: 600}, {x: 1400, y: 600},
    {x: 1400, y: 700}, // Right center
    {x: 1400, y: 800}, // Right bottom
    // --- Blue Start (Right arm, bottom row, moving left) ---
    {x: 1300, y: 800}, {x: 1200, y: 800}, {x: 1100, y: 800}, {x: 1000, y: 800}, {x: 900, y: 800},
    // Bottom arm, right col, moving down
    {x: 800, y: 900}, {x: 800, y: 1000}, {x: 800, y: 1100}, {x: 800, y: 1200}, {x: 800, y: 1300}, {x: 800, y: 1400},
    {x: 700, y: 1400}, // Bottom center
    {x: 600, y: 1400}, // Bottom left
    // --- Yellow Start (Bottom arm, left col, moving up) ---
    {x: 600, y: 1300}, {x: 600, y: 1200}, {x: 600, y: 1100}, {x: 600, y: 1000}, {x: 600, y: 900},
    // Left arm, bottom row, moving left
    {x: 500, y: 800}, {x: 400, y: 800}, {x: 300, y: 800}, {x: 200, y: 800}, {x: 100, y: 800}, {x: 0, y: 800},
    {x: 0, y: 700}, // Left center
    {x: 0, y: 600}  // Left top
  ],

  // Home stretches (5 slots each)
  homeStretch: {
    // 2: Green (Moves right on Left arm middle row)
    2: [{x: 100, y: 700}, {x: 200, y: 700}, {x: 300, y: 700}, {x: 400, y: 700}, {x: 500, y: 700}],
    // 1: Red (Moves down on Top arm middle col)
    1: [{x: 700, y: 100}, {x: 700, y: 200}, {x: 700, y: 300}, {x: 700, y: 400}, {x: 700, y: 500}],
    // 4: Blue (Moves left on Right arm middle row)
    4: [{x: 1300, y: 700}, {x: 1200, y: 700}, {x: 1100, y: 700}, {x: 1000, y: 700}, {x: 900, y: 700}],
    // 3: Yellow (Moves up on Bottom arm middle col)
    3: [{x: 700, y: 1300}, {x: 700, y: 1200}, {x: 700, y: 1100}, {x: 700, y: 1000}, {x: 700, y: 900}]
  },

  // Base positions (4 slots for each color)
  bases: {
    2: [{x: 150, y: 150}, {x: 350, y: 150}, {x: 150, y: 350}, {x: 350, y: 350}], // Green Base (Top Left)
    1: [{x: 1050, y: 150}, {x: 1250, y: 150}, {x: 1050, y: 350}, {x: 1250, y: 350}], // Red Base (Top Right)
    4: [{x: 1050, y: 1050}, {x: 1250, y: 1050}, {x: 1050, y: 1250}, {x: 1250, y: 1250}], // Blue Base (Bottom Right)
    3: [{x: 150, y: 1050}, {x: 350, y: 1050}, {x: 150, y: 1250}, {x: 350, y: 1250}] // Yellow Base (Bottom Left)
  },

  // Home center point (x,y of center point directly)
  homeCenter: {x: 750, y: 750}
};

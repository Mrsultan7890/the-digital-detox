-- Seed Data for Digital Detox Game

-- Insert Categories
INSERT INTO categories (name, description, icon, color, sort_order) VALUES
('Internet Detective', 'Web research and fact-finding missions', '🔍', '#3498db', 1),
('Science Explorer', 'Discover human body, biology, and physics', '🔬', '#2ecc71', 2),
('History Hunter', 'Explore historical events and figures', '📜', '#e74c3c', 3),
('Tech Puzzles', 'Decode, encrypt, and solve logic problems', '💻', '#9b59b6', 4),
('Nature Quest', 'Geography, animals, and environment', '🌍', '#27ae60', 5),
('Culture Voyage', 'Languages, traditions, and arts', '🎭', '#f39c12', 6),
('Math Mysteries', 'Number puzzles and patterns', '🔢', '#e67e22', 7);

-- Insert Sample Tasks (Beginner Level)

-- Internet Detective - Beginner
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(1, 'Capital Quest', 'Find the capital of a country', 'beginner', 1, 'search_quest', 'What is the capital of Japan?', 'Tokyo', 'It is the largest city in Japan', 'Think of a major Asian metropolis', 'It hosted Olympics in 2020 (held in 2021)', 10),
(1, 'Tech Founder', 'Research about tech companies', 'beginner', 2, 'search_quest', 'Who founded Microsoft?', 'Bill Gates', 'American billionaire philanthropist', 'Co-founder with Paul Allen', 'First name starts with B', 10),
(1, 'Tallest Building', 'Find architectural records', 'beginner', 3, 'search_quest', 'What is the tallest building in the world (as of 2024)?', 'Burj Khalifa', 'Located in Dubai, UAE', 'Over 800 meters tall', 'Name starts with B', 10);

-- Science Explorer - Beginner
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(2, 'Bone Count', 'Learn about human skeleton', 'beginner', 1, 'search_quest', 'How many bones are in an adult human body?', '206', 'More than 200', 'Babies have more bones that fuse over time', 'Between 200-210', 15),
(2, 'Heart Rate', 'Understand cardiovascular system', 'beginner', 2, 'search_quest', 'What is the normal resting heart rate for adults (in beats per minute range)?', '60-100', 'Between 50 and 120', 'Most healthy adults fall in this range', 'Starts at 60', 15),
(2, 'DNA Structure', 'Genetics basics', 'beginner', 3, 'search_quest', 'What shape is DNA described as?', 'Double Helix', 'Think of a twisted ladder', 'Two strands spiraling', 'Named after a spiral shape', 15);

-- History Hunter - Beginner
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(3, 'Moon Landing', 'Space exploration history', 'beginner', 1, 'search_quest', 'In which year did humans first land on the moon?', '1969', 'During the Cold War space race', '1960s decade', 'Apollo 11 mission', 15),
(3, 'Ancient Wonder', 'Seven wonders research', 'beginner', 2, 'search_quest', 'Which ancient wonder still stands today?', 'Great Pyramid of Giza', 'Located in Egypt', 'Oldest of the seven wonders', 'Built by Pharaohs', 15);

-- Math Mysteries - Beginner
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(7, 'Perfect Square', 'Number theory basics', 'beginner', 1, 'search_quest', 'What is 12 squared (12²)?', '144', 'Multiply 12 by itself', 'Greater than 100', '12 × 12', 10),
(7, 'Pi Value', 'Mathematical constants', 'beginner', 2, 'search_quest', 'What are the first 5 digits of Pi (π)?', '3.1415', 'Starts with 3', 'Used in circle calculations', 'Famous mathematical constant', 10);

-- Insert Sample Intermediate Tasks

-- Tech Puzzles - Intermediate
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(4, 'Caesar Cipher', 'Decode encrypted message', 'intermediate', 15, 'cipher', 'Decode this message with Caesar cipher (shift 3): GLJLWDO GHWRA', 'DIGITAL DETOX', 'Each letter is shifted by 3 positions', 'D becomes G, E becomes H', 'Shift back by 3 positions', 25),
(4, 'Binary Challenge', 'Convert binary to text', 'intermediate', 16, 'cipher', 'What does this binary represent: 01001000 01001001', 'HI', 'Each 8 bits = 1 character', 'Use ASCII table', 'H=72, I=73 in decimal', 25);

-- Nature Quest - Intermediate
INSERT INTO tasks (category_id, title, description, difficulty, level_number, task_type, question, correct_answer, hint_1, hint_2, hint_3, points_reward) VALUES
(5, 'Ocean Deep', 'Ocean exploration', 'intermediate', 12, 'search_quest', 'What is the deepest point in the ocean called?', 'Mariana Trench', 'Located in Pacific Ocean', 'Deeper than Mount Everest is tall', 'Named after Mariana Islands', 20),
(5, 'Fastest Animal', 'Animal kingdom records', 'intermediate', 13, 'search_quest', 'What is the fastest land animal?', 'Cheetah', 'Found in Africa', 'Can reach 70 mph', 'Big cat species', 20);

-- Insert Sample Achievements
INSERT INTO achievements (name, description, icon, requirement_type, requirement_value) VALUES
('First Steps', 'Complete your first task', '🎯', 'tasks_completed', 1),
('Knowledge Seeker', 'Complete 10 tasks', '📚', 'tasks_completed', 10),
('Master Researcher', 'Complete 50 tasks', '🏆', 'tasks_completed', 50),
('Point Collector', 'Earn 100 points', '💰', 'points', 100),
('Point Master', 'Earn 1000 points', '💎', 'points', 1000),
('Week Warrior', 'Maintain 7-day streak', '🔥', 'streak', 7),
('Month Champion', 'Maintain 30-day streak', '⭐', 'streak', 30),
('Category Expert', 'Complete all tasks in a category', '👑', 'category_master', 1);

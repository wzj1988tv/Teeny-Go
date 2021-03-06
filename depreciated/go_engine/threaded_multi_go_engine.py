from cython_go_engine import GoEngine
from cython_multi_go_engine import main
import numpy as np
import time
from multiprocessing import Process

class MultiGoEngine(object):

    # 5. make moves
    # 6. remove inactive games
    # 6. get board state tensor
    # 7. return state tensor

    def __init__(self, num_games=100):
        self.num_games = num_games
        self.active_games = []
        self.games = {}
        self.move_tensor = None
        self.generate_game_objects()

        ##########################
        # Main Game Step Methods #
        ##########################

    def take_game_step(self, move_tensor):

        self.input_move_tensor(move_tensor)

        self.remove_invalid_moves()

        self.make_moves()

        self.remove_inactive_games()

        return self.get_game_states()

    def input_move_tensor(self, move_tensor):
        self.move_tensor = move_tensor

    def remove_invalid_moves(self):

        # clear move tensor
        self.invalid_move_tensor = []
        # start pool thread

        processes = []
        for game in self.active_games:
            p = Process(target=self.get_single_invalid_move, args=game)
            p.start()
            processes.append(p)

        for p in processes:
            p.join()

        self.move_tensor[:,0:81] = self.move_tensor[:,0:81] - np.concatenate(self.invalid_move_tensor)

    def get_single_invalid_move(self, game):
        return self.invalid_move_tensor.append(self.games[game].get_invalid_moves())

    def make_moves(self):

        # choose move based on weighted probability
        # check to see if move is pass or not
        # if pass, pass
        # else: make move
        processes = []
        for game in self.active_games:
            p = Process(target=self.make_single_move, args=game)
            p.start()
            processes.append(p)

        for p in processes:
            p.join()


    def make_single_move(self, input):
        num, game = input[0], input[1]
        moves = list(range(82))
        move = np.random.choice(moves, p=self.move_tensor[num][0:82]/np.sum(self.move_tensor[num][0:82]))

        if move == 81:
            self.games[game].make_pass_move()

        else:
            self.games[game].make_move([move//9, move%9])



    def get_active_game_states(self):
        states_tensor = []
        for game in self.active_games:
            states_tensor.append(self.games[game].get_board_tensor())
        return np.concatenate(states_tensor)

    def get_all_game_states(self):
        states_tensor = []
        for i in range(self.num_games):
            states_tensor.append(self.games["G"+str(i)].get_board_tensor())
        return np.concatenate(states_tensor)

    def remove_inactive_games(self):

        for game in self.active_games:
            if self.games[game].is_playing == False:
                self.active_games.remove(game)

        #######################
        # Misc Engine Methods #
        #######################

    def generate_game_objects(self):
        for i in range(self.num_games):
            self.games["G"+str(i)] = GoEngine()
            self.active_games.append("G"+str(i))

    def reset_games(self):
        for i in range(self.num_games):
            self.games["G"+str(i)].new_game()

def main_two():
    n = 2000
    mge = MultiGoEngine(num_games=n)
    mge.move_tensor = np.ones([n, 83])
    t = time.time()
    mge.get_active_game_states()
    mge.remove_invalid_moves()
    mge.make_moves()
    mge.remove_inactive_games()
    print("Game Step Time:", round(time.time()-t, 3), "s")


if __name__ == "__main__":
    main_two()

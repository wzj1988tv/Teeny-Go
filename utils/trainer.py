import logging
import time
import os

import torch
import numpy as np

from multi_go_engine import MultiGoEngine

class GoTrainer(object):

    def __init__(self, network=None):

        if network==None:
            raise ValueError("no network supplied")

        # initialize model
        self.network = network

        # save network attributes
        self.num_res = self.network.num_res_blocks
        self.num_channels = self.netork.num_channels

        # set model name
        self.model_name = "Model-R{}-C{}".format(self.num_res, self.num_channels)

        # load game engine
        self.engine = MultiGoEngine()

    def save_model(self, version):
        path = "models/Model-R{}-C{}/".format(self.num_res, self.num_channels)
        filename = "Model-R{}-C{}-V{}.pt".format(self.num_res, self.num_channels, version)
        torch.save(self.network.state_dict(), path+filename)

    def load_model(self, version):
        path = "models/Model-R{}-C{}/".format(self.num_res, self.num_channels)
        filename = "Model-R{}-C{}-V{}.pt".format(self.num_res, self.num_channels, version)
        self.network.load_state_dict(torch.load(path+filename))

    def play_through_games(self, num_games):
        # reset and clear engine
        del(self.engine)
        self.engine = MultiGoEngine(num_games)

        # main play loop
        while self.engine.is_playing_games():

            state_tensor = self.engine.get_active_game_states()
            move_tensor = self.network.forward(state_tensor)
            self.engine.take_game_step(move_tensor)

    def train(self):

        # while training:

            # play through games

            # train on new game data

            # save model

            # save game data
        pass

    def save_data(self):
        pass

    def load_data(self):
        pass

    def play_game(self):
        pass

    def get_game_data(self):
        pass
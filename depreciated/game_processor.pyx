import os
from tqdm import tqdm

#path = "GoSampleData/godata1.sgf"


cdef get_sgf_raw_data(str path):
    file = open(path)
    lines = file.readlines(0)
    file.close()
    return lines

cdef clean_sgf_data(list raw_data):
    cdef list data_holder = []
    cdef list data = []
    cdef int i
    cdef str j
    del(raw_data[0])
    del(raw_data[0])
    for i in range(1, len(raw_data)):
        data_holder = data_holder + raw_data[i].split(';')
    for j in data_holder:
        if j != '':
            data.append(j[:5])

    return data

cdef get_winner(list line):
    cdef str winner
    winner = line[2]
    winner = winner.split('RE')[1][1]
    if winner == "W":
        return "white"
    if winner == "B":
        return "black"
    return winner

cdef translate_data(list raw):
    cdef list letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
    cdef list lower_letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
    cdef list data = []
    cdef str i
    for i in raw:
        #print(i)
        if len(i) > 4:
            if i[2] in lower_letters and i[3] in lower_letters:
                data.append(i[2].upper()+str(letters.index(i[3].upper())))

    return data


cdef get_data(str path):
    raw = get_sgf_raw_data(path)
    winner = get_winner(raw)
    raw = clean_sgf_data(raw)
    data = translate_data(raw)
    return data, winner



cdef copy(list k):
    cdef int i
    cdef list new_list = []
    for i in range(len(k)):
        new_list.append(k[i][:])
    return new_list


cdef initialize_board():
            cdef int i
            board = []
            for i in range(9):
                board.append([0, 0, 0, 0, 0, 0, 0, 0, 0])
            return board


# returns an empty board with the move about to be made
cdef position_to_coordinates(str move):
            cdef list letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
            return [letters.index(move[0]), int(move[1])]


cdef get_y(list boardy, list move):
            cdef int i
            cdef int j
            cdef list y
            y = copy(boardy)
            for i in range(9):
                for j in range(9):
                    if y[j][i] == 0:
                        y[j][i] = 0.2

            for i in range(9):
                for j in range(9):
                    if y[j][i] != 0.2:
                        y[j][i] = 0

            y[move[0]][move[1]] = 1
            return y


cpdef play(list data, str winner):
            cdef str turn = "black"
            cdef list board = initialize_board()
            cdef list x_data = []
            cdef list y_data = []
            cdef list boardy
            cdef int stand_off
            cdef int white_score = 0
            cdef int black_score = 0
            cdef int i
            cdef int j
            cdef str move_str
            cdef list move
            for move_str in data:


                type_for_capture = 0
                move = position_to_coordinates(move_str)
                x = copy(board)
                boardy = copy(board)
                y = get_y(boardy, move)

                if board[move[0]][move[1]] == 0:
                    # stand off is set to False

                    stand_off = 0
                    #if the position is good then...
                    if move is not None:
                        move_state = board[move[0]][move[1]]
                        # if the board space is empty...
                        if move_state == 0:
                            # place white or black depending on the turn
                            if turn == "white":
                                board[move[0]][move[1]] = 1
                            elif turn == "black":
                                board[move[0]][move[1]] = -1
                            # if
                            check_captures = check_capture_pieces(move, board)

                            if check_captures == "white" or check_captures == "black":
                                if check_captures == "white":
                                    type_for_capture = 1
                                    stand_off = 1

                                if check_captures == "black":
                                    type_for_capture = -1
                                    stand_off = 1

                            if check_captures == 0 or stand_off == 1:
                                if turn == "white":
                                    turn = "black"
                                elif turn == "black":
                                    turn = "white"

                            if True:
                                if turn == winner:

                                    if winner == "white":
                                        x_data.append(copy(x))
                                        y_data.append(copy(y))



                                    if winner == "black":

                                        for i in range(9):
                                            for j in range(9):
                                                if x[j][i] == 1:
                                                    x[j][i] = -2

                                        for i in range(9):
                                            for j in range(9):
                                                if x[j][i] == -1:
                                                    x[j][i] = 1

                                        for i in range(9):
                                            for j in range(9):
                                                if x[j][i] == -2:
                                                    x[j][i] = -1

                                        x_data.append(copy(x))
                                        y_data.append(copy(y))




                            if check_captures == 1:
                                board[move[0]][move[1]] = 0

                if type_for_capture != 0:
                    board = capture_pieces(type_for_capture, board, white_score, black_score)
            return x_data, y_data


cdef capture_pieces(int type_for_capture, list board, int white_score, int black_score):
            cdef int i
            cdef int j
            cdef int location_state

            for i in range(9):
                for j in range(9):
                    location_state = board[i][j]
                    if location_state != 0 and location_state == type_for_capture:
                        group = get_group([i, j], location_state, board)
                        if group != []:
                            free = check_neighbors(group, location_state, board)
                            if free == "False":
                                board = remove_group(group, white_score, black_score, board)
            return board


cdef check_capture_pieces(list position, list board):
            cdef int i
            cdef int j
            killing_itself = 0
            for i in range(9):
                for j in range(9):
                    location_state = board[i][j]
                    if location_state != 0:
                        group = get_group([i, j], location_state, board)
                        if group != []:
                            free = check_neighbors(group, location_state, board)
                            if free == "False":
                                    if position in group:
                                        killing_itself = 1
                                    if location_state == 1 and board[position[0]][position[1]] != 1:
                                        return "white"
                                    if location_state == -1 and board[position[0]][position[1]] != -1:
                                        return "black"

            return killing_itself


cdef check_neighbors(list group, int state_type, list board):
            cdef str liberty = "False"
            cdef list position
            cdef int a
            cdef int b

            for position in group:

                a, b = position[0], position[1]

                if a < 8:
                    if board[a+1][b] == 0:
                        return True

                if a > 0:
                    if board[a-1][b] == 0:
                        return True

                if b < 8:
                    if board[a][b+1] == 0:
                        return True

                if b > 0:
                    if board[a][b-1] == 0:
                        return True

            return liberty


cdef get_group(list position, int state_type, list board):
            cdef list stone_group = []
            stone_group.append(position)
            cdef int i
            cdef int j
            cdef int a
            cdef int b
            cdef list pos
            for j in range(20):
                for pos in stone_group:
                    a, b = pos[0], pos[1]
                    if a > 0:
                        if board[a-1][b] == state_type and [a-1, b] not in stone_group:
                            stone_group.append([a-1, b])

                    if a < 8:
                        if board[a+1][b] == state_type and [a+1, b] not in stone_group:
                            stone_group.append([a+1, b])

                    if b > 0:
                        if board[a][b-1] == state_type and [a, b-1] not in stone_group:
                            stone_group.append([a, b-1])

                    if b < 8:
                        if board[a][b+1] == state_type and [a, b+1] not in stone_group:
                            stone_group.append([a, b+1])

            return stone_group


cdef remove_group(list group, int white_score, int black_score, list board):
            if board[group[0][0]][group[0][1]] == 1:
                black_score = black_score + len(group)
            if board[group[0][0]][group[0][1]] == -1:
                white_score = white_score + len(group)
            cdef list elmnt
            for elmnt in group:
                board[elmnt[0]][elmnt[1]] = 0
            return board


cpdef process_sgf(str path):
        cdef str winner
        cdef list data
        cdef list x
        cdef list y
        data, winner = get_data(path)
        x, y = play(data, winner)
        return x, y

cpdef process_multi_sgf(list paths):
            cdef list x_multi = []
            cdef list y_multi = []
            cdef str winner
            cdef list data
            cdef list x
            cdef list y
            cdef int list
            for path in tqdm(range(len(paths))):
                data, winner = get_data(paths[path])
                x, y = play(data, winner)
                x_multi = x_multi + copy(x)
                y_multi = y_multi + copy(y)
            

            return x_multi, y_multi

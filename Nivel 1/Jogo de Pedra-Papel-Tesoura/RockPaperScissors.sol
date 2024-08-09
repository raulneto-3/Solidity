// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Move { any, Rock, Paper, Scissors }
    enum GameStatus { NotStarted, WaitingForPlayer, WaitingForMoves, Finished }

    struct Game {
        address player1;
        address player2;
        Move movePlayer1;
        Move movePlayer2;
        GameStatus status;
        uint256 betAmount;
    }

    uint256 public gameIdCounter = 0;
    mapping(uint256 => Game) public games;

    // Eventos para notificar os clientes sobre atualizações
    event GameCreated(uint256 gameId, address creator, uint256 betAmount);
    event PlayerJoined(uint256 gameId, address player, uint256 betAmount);
    event MoveMade(uint256 gameId, address player, Move move);
    event GameResult(uint256 gameId, string result);

    // Cria um novo jogo
    function createGame() public payable {
        uint256 gameId = gameIdCounter++;
        games[gameId] = Game(msg.sender, address(0), Move.any, Move.any, GameStatus.WaitingForPlayer, msg.value);
        emit GameCreated(gameId, msg.sender, msg.value);
    }

    // Outro jogador entra no jogo
    function joinGame(uint256 gameId) public payable {
        require(games[gameId].status == GameStatus.WaitingForPlayer, "Game is not waiting for a player.");
        require(games[gameId].player1 != msg.sender, "Creator cannot join their own game.");
        require(games[gameId].betAmount == msg.value, "Bet amount does not match.");

        games[gameId].player2 = msg.sender;
        games[gameId].status = GameStatus.WaitingForMoves;
        emit PlayerJoined(gameId, msg.sender, msg.value);
    }

    // Jogador faz sua jogada
    function makeMove(uint256 gameId, Move move) public {
        require(games[gameId].status == GameStatus.WaitingForMoves, "Game is not waiting for moves.");
        require(games[gameId].player1 == msg.sender || games[gameId].player2 == msg.sender, "You are not part of this game.");

        if (games[gameId].player1 == msg.sender) {
            games[gameId].movePlayer1 = move;
        } else if (games[gameId].player2 == msg.sender) {
            games[gameId].movePlayer2 = move;
        }

        // Se ambos jogadores fizeram suas jogadas, atualiza o status para Finished
        if (games[gameId].movePlayer1 != Move.any && games[gameId].movePlayer2 != Move.any) {
            if (games[gameId].movePlayer1 == games[gameId].movePlayer2) {
                // Empate
                payable(games[gameId].player1).transfer(games[gameId].betAmount);
                payable(games[gameId].player2).transfer(games[gameId].betAmount);
                emit GameResult(gameId, "Draw");
            } else {
                if ((games[gameId].movePlayer1 == Move.Rock && games[gameId].movePlayer2 == Move.Scissors) ||
                    (games[gameId].movePlayer1 == Move.Paper && games[gameId].movePlayer2 == Move.Rock) ||
                    (games[gameId].movePlayer1 == Move.Scissors && games[gameId].movePlayer2 == Move.Paper)) {
                    // Jogador 1 vence
                    payable(games[gameId].player1).transfer(games[gameId].betAmount * 2);
                    emit GameResult(gameId, "Player 1 wins");
                } else {
                    // Jogador 2 vence
                    payable(games[gameId].player2).transfer(games[gameId].betAmount * 2);
                    emit GameResult(gameId, "Player 2 wins");
                }
            }

            games[gameId].status = GameStatus.Finished;
        }

        emit MoveMade(gameId, msg.sender, move);
    }

    // Calcula e retorna o resultado do jogo
    function getResult(uint256 gameId) internal view returns (string memory) {
        if (games[gameId].movePlayer1 == games[gameId].movePlayer2) {
            return "Draw";
        }
        if ((games[gameId].movePlayer1 == Move.Rock && games[gameId].movePlayer2 == Move.Scissors) ||
            (games[gameId].movePlayer1 == Move.Scissors && games[gameId].movePlayer2 == Move.Paper) ||
            (games[gameId].movePlayer1 == Move.Paper && games[gameId].movePlayer2 == Move.Rock)) {
            return "Player 1 wins";
        } else {
            return "Player 2 wins";
        }
    }

    // Função para visualizar o resultado do jogo
    function viewResult(uint256 gameId) public view returns (string memory) {
        require(games[gameId].status == GameStatus.Finished, "Game is not finished yet.");
        return getResult(gameId);
    }
}
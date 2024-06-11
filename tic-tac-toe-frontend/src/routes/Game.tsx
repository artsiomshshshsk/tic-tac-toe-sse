import '../App.css'
import {Button} from '@/components/ui/button.tsx';
import useAuthenticated from '@/hooks/useAuthenticated.ts';
import {EventSourcePolyfill} from 'ng-event-source';
import {useLocation} from 'react-router-dom';
import {useEffect, useState} from "react";
import {
    Cell,
    GameEvent,
    GameResult,
    GameUser,
    getGameHistory,
    getUserData,
    makeMove,
    subscribe
} from "../api/GameApiClient.ts";
import Board from "../components/Board.tsx";
import {Step} from "@/routes/Step.tsx";
import {Avatar} from "@/components/ui/avatar.tsx";
import {AvatarFallback, AvatarImage} from "@radix-ui/react-avatar";
import {Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow} from "@/components/ui/table.tsx";


type result = "win" | "lose" | "draw";


type GameItem = {
    id: number;
    opponent: {
        username: string;
        avatarUrl: string;
    }
    gameResult: result;
    playedAt: string;
}


function Game() {
    const location = useLocation();

    useAuthenticated();
    const { username } = location.state || { username: localStorage.getItem('username') };
    
    const [eventSource, setEventSource] = useState<undefined|EventSourcePolyfill>(undefined);
    const [step, setStep] = useState<Step>(Step.START);
    const [gameId, setGameId] = useState<number | undefined>(undefined);
    const [currentPlayer, setCurrentPlayer] = useState<string | undefined>(undefined);
    const [board, setBoard] = useState<Cell[][]>(Array(3).fill(null).map(() => Array(3).fill("EMPTY" as Cell)));
    const [winner, setWinner] = useState<string | undefined>(undefined);
    const [avatarUrl, setAvatarUrl] = useState<string | undefined>(undefined);

    const [user1, setUser1] = useState<GameUser | undefined>(undefined);
    const [user2, setUser2] = useState<GameUser | undefined>(undefined);


    const [gameHistory, setGameHistory] = useState<GameResult[]>([]);


    const gamesToShow = gameHistory.map((game) => {
        const gameRes: GameItem =  {
            id: game.id,
            opponent: {
                username: game.firstPlayer.username === username ? game.secondPlayer.username : game.firstPlayer.username,
                avatarUrl: game.firstPlayer.username === username ? game.secondPlayer.avatarUrl : game.firstPlayer.avatarUrl
            },
            gameResult: game.winner == null ? "draw" : game.winner.username === username ? "win" : "lose",
            playedAt: game.playedAt
        }
        return gameRes;
    })

    const myUser = user1?.username === username ? user1 : user2;
    const opponentUser = user1?.username === username ? user2 : user1;

    const myTurn = currentPlayer === username;
    
    useEffect(() => {
        return () => {
            if(eventSource) {
                eventSource.close();
            }
        }
    }, [eventSource])

    useEffect(() => {
        if(username) {
            getUserData().then((data) => {
                setAvatarUrl(data.avatarUrl);
            });
        }
    }, [username]);


    useEffect(() => {
        if(username) {
            getGameHistory().then((data) => {
                setGameHistory(data);
            });
        }
    }, [username, step]);


    const handleGameEvent = (event: GameEvent) => {
        if(event.event === "GAME_STARTED") {
            setStep(Step.GAME);
            setGameId(event.gameId);
        }
        else if(event.event === "GAME_UPDATED") {
            console.log("Game updated");

        } else if(event.event === "GAME_ENDED") {
            console.log("Game ended");
            setStep(Step.END);
            setWinner(event.winner);
        }

        setUser1(event.user1);
        setUser2(event.user2);

        setCurrentPlayer(event.currentPlayer);
        setBoard(event.board);
    }


    const handleFindGame = () => {
        const es = subscribe(handleGameEvent);
        setEventSource(es);
        setStep(Step.WAITING);
    }


    const handleGameEnd = () => {
        setStep(Step.START);
        setWinner(undefined);
        setGameId(undefined);
        setBoard(Array(3).fill(null).map(() => Array(3).fill("EMPTY" as Cell)));
        if(eventSource) {
            eventSource.close();
            setEventSource(undefined);
        }
    }

    if(step === Step.START) {
        return <div className={"App mt-20 flex items-center flex-col"}>
            <Avatar className={'mt-10 w-32 h-32'}>
                <AvatarImage src={avatarUrl} />
                <AvatarFallback>CN</AvatarFallback>
            </Avatar>
            <h1>Hi {username}! Press button to start playing with random opponent</h1>
            <Button onClick={handleFindGame}>Find game</Button>
            {gameHistory.length === 0 && <h1>No games played yet</h1>}
            {gameHistory.length > 0 && <div>
                <Table>
                    <TableCaption>Your game history</TableCaption>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-[100px]">Id</TableHead>
                            <TableHead>Result</TableHead>
                            <TableHead>Opponent</TableHead>
                            <TableHead>Date</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {gamesToShow.map((gameRow) => (
                            <TableRow key={gameRow.id}>
                                <TableCell className="font-medium">{gameRow.id}</TableCell>
                                <TableCell className="font-medium">{gameRow.gameResult}</TableCell>
                                <TableCell className="font-medium">
                                    <div className={"flex items-center space-x-3.5"}>
                                        {gameRow.opponent.username}
                                        <Avatar className="w-8 h-8 border-2 border-white rounded-full overflow-hidden ml-2.5">
                                            <AvatarImage src={gameRow.opponent.avatarUrl} className="object-cover w-full h-full"/>
                                            <AvatarFallback>CN</AvatarFallback>
                                        </Avatar>
                                    </div>
                                </TableCell>
                                <TableCell className="font-medium">{gameRow.playedAt}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </div>}
        </div>
    }
    else if(step === Step.WAITING) {
        return <div className={"App mt-60 flex items-center flex-col"}>
            <h1>Finding game for you...</h1>
            <Avatar className={'mt-10 w-32 h-32'}>
                <AvatarImage src={avatarUrl} />
                <AvatarFallback>CN</AvatarFallback>
            </Avatar>
        </div>
    }
    else if(step === Step.GAME) {
        return <div className={"App"}>
            <div className="flex flex-col items-center justify-center p-4 text-white rounded-lg shadow-md">
                <h1 className="text-2xl font-bold mb-4">{myUser?.username} (me) vs {opponentUser?.username}</h1>
                <div className="flex space-x-6">
                    <Avatar className="w-24 h-24 border-2 border-white rounded-full overflow-hidden">
                        <AvatarImage src={myUser?.avatarUrl} className="object-cover w-full h-full"/>
                        <AvatarFallback>CN</AvatarFallback>
                    </Avatar>
                    <Avatar className="w-24 h-24 border-2 border-white rounded-full overflow-hidden">
                        <AvatarImage src={opponentUser?.avatarUrl} className="object-cover w-full h-full"/>
                        <AvatarFallback>CN</AvatarFallback>
                    </Avatar>
                </div>
            </div>
            {myTurn ? <h1>Your turn...</h1> : <h1>Waiting for the other player...</h1>}
            <Board disabled={!myTurn} board={board} onCellClick={(x, y) => {
                console.log(`Making move: x: ${x}, y: ${y}`)
                makeMove(gameId!, {x, y, playerName: username!})
                    .then(() => console.log("Move made"))
                    .catch((error) => console.log("Error making move: ", error))
            }}/>
        </div>
    }
    else if(step === Step.END) {

        const text = winner != undefined ? `${winner === username ? "You": "Your opponent"} won!` : "It's a draw"

        return <div className={"App"}>
            <div className="flex justify-center items-center mb-6 space-x-6">
                {winner === myUser?.username &&
                    <Avatar className="w-24 h-24 mt-10 border-2 border-white rounded-full overflow-hidden">
                        <AvatarImage src={myUser?.avatarUrl} className="object-cover w-full h-full"/>
                        <AvatarFallback>CN</AvatarFallback>
                    </Avatar>}
                {winner === opponentUser?.username && <Avatar className="w-24 h-24 border-2 border-white rounded-full overflow-hidden">
                    <AvatarImage src={opponentUser?.avatarUrl} className="object-cover w-full h-full"/>
                    <AvatarFallback>CN</AvatarFallback>
                </Avatar>}

                {winner == undefined && <div className="flex space-x-6">
                    <Avatar className="w-24 h-24 mt-10 border-2 border-white rounded-full overflow-hidden">
                        <AvatarImage src={myUser?.avatarUrl} className="object-cover w-full h-full"/>
                        <AvatarFallback>CN</AvatarFallback>
                    </Avatar>
                    <Avatar className="w-24 h-24 border-2 border-white rounded-full overflow-hidden">
                        <AvatarImage src={opponentUser?.avatarUrl} className="object-cover w-full h-full"/>
                        <AvatarFallback>CN</AvatarFallback>
                    </Avatar>
                </div>}
            </div>
            <h2>{text}</h2>
            <Board disabled board={board}/>
            <button style={{
                margin: "20px",
                width: "100px",
            }} className={'my-button'} onClick={handleGameEnd}>Play Again
            </button>
        </div>
    }
}

export default Game

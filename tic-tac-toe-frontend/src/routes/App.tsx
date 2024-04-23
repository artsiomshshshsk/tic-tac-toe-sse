import '../App.css'
import { Button } from '@/components/ui/button.tsx';
import { useLocation } from 'react-router-dom';
import MyForm from "../components/MyForm.tsx";
import {useEffect, useState} from "react";
import {Cell, GameEvent, makeMove, subscribe} from "../api/Api.ts";
import Board from "../components/Board.tsx";


export enum Step {
    START,
    WAITING,
    GAME,
    END
}

function App() {

    // const [username, setUsername] = useState<string | undefined>(undefined);
    
    const location = useLocation();
    const { username } = location.state || {};
    
    const [eventSource, setEventSource] = useState<undefined|EventSource>(undefined);
    const [step, setStep] = useState<Step>(Step.START);
    const [gameId, setGameId] = useState<number | undefined>(undefined);
    const [currentPlayer, setCurrentPlayer] = useState<string | undefined>(undefined);
    const [board, setBoard] = useState<Cell[][]>(Array(3).fill(null).map(() => Array(3).fill("EMPTY" as Cell)));
    const [winner, setWinner] = useState<string | undefined>(undefined);

    const myTurn = currentPlayer === username;


    useEffect(() => {
        return () => {
            if(eventSource) {
                eventSource.close();
            }
        }
    }, [eventSource])


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

        setCurrentPlayer(event.currentPlayer);
        setBoard(event.board);
    }


    const handleFindGame = () => {
        const es = subscribe(username, handleGameEvent);
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
        return <div className={"App"}>
            <h1>Hi {username}! Press button to start playing with random opponent</h1>
            <Button onClick={handleFindGame}>Find game</Button>
        </div>
    }
    else if(step === Step.WAITING) {
        return <div className={"App"}>
            <h1>Finding game for you...</h1>
        </div>
    }
    else if(step === Step.GAME) {
        return <div className={"App"}>
            {myTurn ? <h1>Your turn...</h1> : <h1>Waiting for the other player...</h1>}
            <Board disabled={!myTurn} board={board} onCellClick={(x,y) => {
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
           <h1>Game over</h1>
            <h2>{text}</h2>
            <Board disabled board={board}/>
            <button style={{
                margin: "20px",
                width: "100px",
            }} className={'my-button'} onClick={handleGameEnd}>Play Again</button>
        </div>
    }
}

export default App

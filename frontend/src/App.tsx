import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import styles from './styles.module.css'
import * as ethereum from '@/lib/ethereum'
import * as main from '@/lib/main'
import { BigNumber } from 'ethers'
import { isAddress } from 'ethers/lib/utils'

type Canceler = () => void
const useAffect = (
  asyncEffect: () => Promise<Canceler | void>,
  dependencies: any[] = []
) => {
  const cancelerRef = useRef<Canceler | void>()
  useEffect(() => {
    asyncEffect()
      .then(canceler => (cancelerRef.current = canceler))
      .catch(error => console.warn('Uncatched error', error))
    return () => {
      if (cancelerRef.current) {
        cancelerRef.current()
        cancelerRef.current = undefined
      }
    }
  }, dependencies)
}

const useWindowSize = () => {
  const [size, setSize] = useState({ height: 0, width: 0 })
  const compute = useCallback(() => {
    const height = Math.min(window.innerHeight, 800)
    const width = Math.min(window.innerWidth, 800)
    if (height < width) setSize({ height, width: height })
    else setSize({ height: width, width })
  }, [])
  useEffect(() => {
    compute()
    window.addEventListener('resize', compute)
    return () => window.addEventListener('resize', compute)
  }, [compute])
  return size
}

const useWallet = () => {
  const [details, setDetails] = useState<ethereum.Details>()
  const [contract, setContract] = useState<main.Main>()
  useAffect(async () => {
    const details_ = await ethereum.connect('metamask')
    if (!details_) return
    setDetails(details_)
    const contract_ = await main.init(details_)
    if (!contract_) return
    setContract(contract_)
  }, [])
  return useMemo(() => {
    if (!details || !contract) return
    return { details, contract }
  }, [details, contract])
}

// function random_rgba() {
//   var o = Math.round, r = Math.random, s = 255;
//   return 'rgba(' + o(r()*s) + ',' + o(r()*s) + ',' + o(r()*s) + ',' + r().toFixed(1) + ')';
// }
// var color = random_rgba();

type Ship = {}
const useBoard = (wallet: ReturnType<typeof useWallet>) => {
  const [board, setBoard] = useState<(null | Ship)[][]>([])
  useAffect(async () => {
    if (!wallet) return
    const onRegistered = (
      id: BigNumber,
      owner: string,
      x: BigNumber,
      y: BigNumber
    ) => {
      console.log('onRegistered (owner) - ',owner)
      //wallet?.contract.setColor(color,owner);
      setBoard(board => {
        return board.map((x_, index) => {
          if (index !== x.toNumber()) return x_
          return x_.map((y_, indey) => {
            if (indey !== y.toNumber()) return y_
            return { owner, index: id.toNumber() }
          })
        })
      })
    }
    const onTouched = (id: BigNumber, x_: BigNumber, y_: BigNumber) => {
      console.log('onTouched')
      const x = x_.toNumber()
      const y = y_.toNumber()
      setBoard(board => {
        return board.map((x_, index) => {
          if (index !== x) return x_
          return x_.map((y_, indey) => {
            if (indey !== y) return y_
            return null
          })
        })
      })
    }
    const updateSize = async () => {
      const [event] = await wallet.contract.queryFilter('Size', 0)
      const width = event.args.width.toNumber()
      const height = event.args.height.toNumber()
      const content = new Array(width).fill(0)
      const final = content.map(() => new Array(height).fill(null))
      setBoard(final)
    }
    const updateRegistered = async () => {
      const registeredEvent = await wallet.contract.queryFilter('Registered', 0)
      registeredEvent.forEach(event => {
        const { index, owner, x, y } = event.args
        onRegistered(index, owner, x, y)
      })
    }
    const updateTouched = async () => {
      const touchedEvent = await wallet.contract.queryFilter('Touched', 0)
      touchedEvent.forEach(event => {
        const { ship, x, y } = event.args
        onTouched(ship, x, y)
      })
    }
    await updateSize()
    await updateRegistered()
    await updateTouched()
    console.log('Registering')
    console.log('Touched', onTouched)
    wallet.contract.on('Registered', onRegistered)
    wallet.contract.on('Touched', onTouched)
    return () => {
      console.log('Unregistering')
      wallet.contract.off('Registered', onRegistered)
      wallet.contract.off('Touched', onTouched)
    }
  }, [wallet])
  return board
}

const Buttons = ({ wallet }: { wallet: ReturnType<typeof useWallet> }) => {
  const next = () => wallet?.contract.turn()
  const register = async () => {  
    
   // wallet?.contract.setShip();
    wallet?.contract.createShip()
      .then(data => {
        if(isAddress(data)) {
          console.log("Success ",data);
          wallet?.contract.register(data);
        }
      })
      .catch( err => {
        console.log("Register error ",err);
      })
    
  }

  return (
    <div style={{ display: 'flex', gap: 5, padding: 5 }}>
      <button onClick={register}>Register</button>
      <button onClick={next}>Turn</button>
    </div>
  )
}


const CELLS = new Array(100 * 100)
export const App = () => {
  const wallet = useWallet()
  const board = useBoard(wallet)
  const size = useWindowSize()
  const st = {
    ...size,
    gridTemplateRows: `repeat(${board?.length ?? 0}, 1fr)`,
    gridTemplateColumns: `repeat(${board?.[0]?.length ?? 0}, 1fr)`,
  }


  const clickMe = (x: GLint, y:GLint) => {
    wallet?.contract.setShip(x,y);
    
    console.log("acc ",wallet!.details.account);
    console.log("coordinates ",x,y);
    
    // let name1:string = wallet!.details.account || '0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199';
    // console.log("name ",name1);
    // await wallet?.contract.getColor(name1)
    // .then(data => {
    //   console.log('get (color) - ',data );
    // })
    
    
  }
  
  return (
    <div className={styles.body}>
      <h1>Welcome to Touché Coulé</h1>
      <div className={styles.grid} style={st}>
          {CELLS.fill(0).map((_, index) => {
            const x = Math.floor(index % board?.length ?? 0)
            const y = Math.floor(index / board?.[0]?.length ?? 0)
            const background = board?.[x]?.[y] ? 'red' : undefined
            return (
              <div onClick={() => clickMe(x,y)} key={index} className={styles.cell} style={{ background }} />
            )
          })}
      </div>
      <Buttons wallet={wallet} />
    </div>
  )
}

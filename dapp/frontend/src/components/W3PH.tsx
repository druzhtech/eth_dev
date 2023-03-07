import { useWeb3React } from '@web3-react/core';
import { Contract, ethers, Signer } from 'ethers';
import {
  ChangeEvent,
  MouseEvent,
  ReactElement,
  useEffect,
  useState
} from 'react';
import styled from 'styled-components';
import WebThreeProjectHubArtifact from '../artifacts/contracts/WebThreeProjectHub.sol/WebThreeProjectHub.json';
import { Provider } from '../utils/provider';
import { SectionDivider } from './SectionDivider';
import { strictEqual } from 'assert';

const StyledDeployContractButton = styled.button`
  width: 180px;
  height: 2rem;
  border-radius: 1rem;
  border-color: blue;
  cursor: pointer;
  place-self: center;
`;

const StyledServiceDiv = styled.div`
  display: grid;
  grid-template-rows: 1fr 1fr 1fr;
  grid-template-columns: 135px 2.7fr 1fr;
  grid-gap: 10px;
  place-self: center;
  align-items: center;
`;

const StyledLabel = styled.label`
  font-weight: bold;
`;

const StyledInput = styled.input`
  padding: 0.4rem 0.6rem;
  line-height: 2fr;
`;

const StyledButton = styled.button`
  width: 150px;
  height: 2rem;
  border-radius: 1rem;
  border-color: blue;
  cursor: pointer;
`;

export function W3PH(): ReactElement {
  const context = useWeb3React<Provider>();
  const { library, active } = context;

  const [signer, setSigner] = useState<Signer>();
  const [w3phContract, setW3phContract] = useState<Contract>();
  const [w3phContractAddr, setW3phContractAddr] = useState<string>('');
  const [recieverAddr, setRecieverAddr] = useState<string>('');

  const [version, setVersion] = useState<string>('');
  const [versionInput, setVersionInput] = useState<string>('');

  const [projType, setProjType] = useState<string>('');
  const [projectInput, setProjectInput] = useState<string>('');

  useEffect((): void => {
    if (!library) {
      setSigner(undefined);
      return;
    }

    setSigner(library.getSigner());
  }, [library]);

  useEffect((): void => {
    if (!w3phContract) {
      return;
    }

    async function getW3phContract(w3phContract: Contract): Promise<void> {
      const _version = await w3phContract.w3phVersion();

      if (_version !== version) {
        setVersion(_version);
      }
    }

    getW3phContract(w3phContract);
  }, [w3phContract, version]);

  function handleDeployContract(event: MouseEvent<HTMLButtonElement>) {
    event.preventDefault();

    // only deploy the W3PH contract one time, when a signer is defined
    if (w3phContract || !signer) {
      return;
    }

    // filter = {
    //   address: w3phContractAddr,
    //   topics: [
    //     utils.id("Transfer(address,address,uint256)"),
    //     hexZeroPad(myAddress, 32)
    //   ]
    // };

    async function deployW3phContract(signer: Signer): Promise<void> {
      const W3PH = new ethers.ContractFactory(
        WebThreeProjectHubArtifact.abi,
        WebThreeProjectHubArtifact.bytecode,
        signer
      );


      try {
        const w3phContract = await W3PH.deploy(1);
        await w3phContract.deployed();
        const vers = await w3phContract.w3phVersion();
        setW3phContract(w3phContract);
        setVersion(vers);
        window.alert(`W3PH deployed to: ${w3phContract.adreess}`);

        setW3phContractAddr(w3phContract.address);
      } catch (error: any) {
        window.alert(
          'Error!' + (error && error.message ? `\n\n${error.message}` : '')
        );
      }
    }

    deployW3phContract(signer);
  }

  function handleInstContract(event: MouseEvent<HTMLButtonElement>) {
    event.preventDefault();

    // only deploy the W3PH contract one time, when a signer is defined
    if (w3phContract || !signer) {
      return;
    }

    async function deployW3phContract(signer: Signer): Promise<void> {

      let address: string = "";

      const W3PH = new ethers.Contract(address, WebThreeProjectHubArtifact.abi, signer);

      try {
        console.log(`W3PH deployed to: ${W3PH.address}`);


        const vers = await W3PH.w3phVersion();

        setW3phContract(W3PH);
        setVersion(vers);

        setW3phContractAddr(W3PH.address);
      } catch (error: any) {
        window.alert(
          'Error!' + (error && error.message ? `\n\n${error.message}` : '')
        );
      }
    }

    deployW3phContract(signer);
  }

  function handleVersionChange(event: ChangeEvent<HTMLInputElement>): void {
    event.preventDefault();
    setVersionInput(event.target.value);
  }

  function handleVersionSubmit(event: MouseEvent<HTMLButtonElement>): void {
    event.preventDefault();

    if (!w3phContract) {
      window.alert('Undefined w3phContract');
      return;
    }

    if (!versionInput) {
      window.alert('Version cannot be empty');
      return;
    }

    async function submitVersion(w3phContract: Contract): Promise<void> {
      try {
        const setVersionTx = await w3phContract.setVersion(versionInput);
        let txReceipt = await setVersionTx.wait();
        console.log("txReceipt: ", txReceipt);
        const newVersion = await w3phContract.w3phVersion();
        window.alert(`Success!\n\ New version is now: ${newVersion}`);
        if (newVersion !== version) {
          setVersion(newVersion);
        }

      } catch (error: any) {
        window.alert(
          'Error!' + (error && error.message ? `\n\n${error.message}` : '')
        );
      }
    }

    submitVersion(w3phContract);
  }

  // Пример вызова функции с отправкой ether
  // https://docs.ethers.org/v5/api/contract/contract/#Contract-functionsCall 
  function handleCreateNewProject(event: MouseEvent<HTMLButtonElement>): void {
    event.preventDefault();

    if (!w3phContract) {
      window.alert('Undefined w3phContract');
      return;
    }

    if (!projectInput) {
      window.alert('Version cannot be empty');
      return;
    }

    async function submitNewProject(w3phContract: Contract): Promise<void> {
      try {

        const options = { value: ethers.utils.parseEther("0.0001") };
        const createProjectTx = await w3phContract.createProject(options);

        // Транзакция
        let txReceipt = await createProjectTx.wait();
        console.log("txReceipt: ", txReceipt);
        const project = await w3phContract.getProjectByOwner(signer?.getAddress());
        window.alert(`Project info: ${project}`);

        // События
        const filter = w3phContract.filters.NewProjectCreated();
        let events = await w3phContract.queryFilter(filter).then(console.log);
        console.log("events: ", events)

      } catch (error: any) {
        window.alert(
          'Error!' + (error && error.message ? `\n\n${error.message}` : '')
        );
      }
    }

    submitNewProject(w3phContract);
  }

  function handleProjTypeChange(event: ChangeEvent<HTMLInputElement>): void {
    event.preventDefault();
    setProjType(event.target.value);
  }

  //TODO: Пример отправки ether на адрес
  function handleSendEthTo(event: MouseEvent<HTMLButtonElement>): void {
    event.preventDefault();

    if (!w3phContract) {
      window.alert('Undefined w3phContract');
      return;
    }

    async function submitSendEth(): Promise<void> {
      try {
        // Отправка 1 ETH
        const tx = signer?.sendTransaction({
          to: recieverAddr,
          value: ethers.utils.parseEther("1.0")
        });

      } catch (error: any) {
        window.alert(
          'Error!' + (error && error.message ? `\n\n${error.message}` : '')
        );
      }
    }

    submitSendEth();
  }

  return (
    <>
      <StyledDeployContractButton
        disabled={!active || w3phContract ? true : false}
        style={{
          cursor: !active || w3phContract ? 'not-allowed' : 'pointer',
          borderColor: !active || w3phContract ? 'unset' : 'blue'
        }}
        onClick={handleDeployContract}
      >
        Deploy Web3 project hub Contract
      </StyledDeployContractButton>

      <StyledDeployContractButton
        disabled={!active || w3phContract ? true : false}
        style={{
          cursor: !active || w3phContract ? 'not-allowed' : 'pointer',
          borderColor: !active || w3phContract ? 'unset' : 'blue'
        }}
        onClick={handleInstContract}
      >
        Inst Web3 project hub Contract
      </StyledDeployContractButton>

      <SectionDivider />
      <StyledServiceDiv>
        <StyledLabel>Contract addr</StyledLabel>
        <div>
          {w3phContractAddr ? (
            w3phContractAddr
          ) : (
            <em>{`<Contract not yet deployed>`}</em>
          )}
        </div>
        {/* empty placeholder div below to provide empty first row, 3rd col div for a 2x3 grid */}
        <div></div>
        <StyledLabel>Current version</StyledLabel>
        <div>
          {version ? version : <em>{`<Contract not yet deployed>`}</em>}
        </div>
        {/* empty placeholder div below to provide empty first row, 3rd col div for a 2x3 grid */}
        <div></div>
        <StyledLabel htmlFor="versionInput">Set new version</StyledLabel>
        <StyledInput
          id="versionInput"
          type="text"
          placeholder={version ? '' : '<Contract not yet deployed>'}
          onChange={handleVersionChange}
          style={{ fontStyle: version ? 'normal' : 'italic' }}
        ></StyledInput>
        <StyledButton
          disabled={!active || !w3phContract ? true : false}
          style={{
            cursor: !active || !w3phContract ? 'not-allowed' : 'pointer',
            borderColor: !active || !w3phContract ? 'unset' : 'blue'
          }}
          onClick={handleVersionSubmit}
        >
          Change
        </StyledButton>

        <StyledLabel htmlFor="projectInput">Create new project</StyledLabel>
        <StyledInput
          id="projectInput"
          type="text"
          placeholder={projType ? '' : '<Contract not yet deployed>'}
          onChange={handleProjTypeChange}
          style={{ fontStyle: projType ? 'normal' : 'italic' }}
        ></StyledInput>
        <StyledButton
          disabled={!active || !w3phContract ? true : false}
          style={{
            cursor: !active || !w3phContract ? 'not-allowed' : 'pointer',
            borderColor: !active || !w3phContract ? 'unset' : 'blue'
          }}
          onClick={handleCreateNewProject}
        >
          Create
        </StyledButton>

      </StyledServiceDiv>
    </>
  );
}

import React from "react";
import Header from "./Header";
import {Spacer} from "./Spacer";
import Overview from "./Overview";
import './LayoutDesktop.css'
import {Transactions} from "./Transactions";
import {AddFunds} from "./AddFunds";
import {MoveFunds} from "./MoveFunds";
import {WithdrawFunds} from "./WithdrawFunds";
import {LockFunds} from "./LockFunds";
import {ManageKeys} from "./ManageKeys";

export const LayoutMobile: React.FC = () => {
  return (
    <div className="LayoutMobile">
      <div className="LayoutMobile-main form-style">
        <Header/>
        <Spacer height={32}/>
        <Overview/>
        <Spacer height={32}/>
        <h3>Transactions</h3>
        <Transactions/>
        <h3><span className="icon">⊕</span>Add Funds to Lottery Pot</h3>
        <AddFunds/>
        <h3><span className="icon">↪</span>Move Funds to Escrow</h3>
        <MoveFunds/>
        <h3><span className="icon">⊖</span>Withdraw Funds from Lottery Pot</h3>
        <WithdrawFunds/>
        <h3><span className="icon">🔒</span>Lock / Unlock Funds</h3>
        <LockFunds/>
        <h3><span className="icon">🔑</span>Manage Keys</h3>
        <ManageKeys/>

      </div>
    </div>
  );
};



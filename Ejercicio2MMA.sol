// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// Contract in progress... Sorry for the inconvenience
contract AutomatedMarket {

    enum OrderType {
        LONG,
        SHORT
    }

    enum StatusOrder {
        CREATED,
        ACCEPTED,
        CANCELED
    }

    struct Order {
        address customer;
        uint256 amount;
        uint256 price;
        bool active;
        OrderType orderType;
        StatusOrder status;
    }

    mapping(uint => Order) orderBook;
    uint256 orderId;

    error noOwnership();
    error bidOrderNotCreated();
    error askOrderNotCreated();
    error notEqualAmount();
    error wrongOwner();

    event orderCreated();
    event bidOrderCompleted(
            Order orderBookBid,
            Order orderBookAsk,
            uint256 timeExecution
    );
    event askOrderCompleted(
            Order orderBookBid,
            Order orderBookAsk,
            uint256 timeExecution
    );

    function setOrder(

        address _customer, 
        uint256 _amount, 
        uint256 _price, 
        OrderType _orderType
        
        ) public {
            orderBook[orderId].customer = _customer;
            orderBook[orderId].amount = _amount;
            orderBook[orderId].price = _price;
            orderBook[orderId].orderType = _orderType;
            orderBook[orderId].status = StatusOrder.CREATED;
            orderBook[orderId].active = true;

            orderId++;
            emit orderCreated();
        }
    
    function cancelOrder(uint256 _orderId) public {
        if(msg.sender != orderBook[_orderId].customer) revert noOwnership();

        if(msg.sender == orderBook[_orderId].customer) {
            orderBook[_orderId].status = StatusOrder.CANCELED;
        }  
    }

    function bidOrderAccepted( uint256 _bidOrder, uint256 _askOrder) public {
        if(orderBook[_bidOrder].status != StatusOrder.CREATED) revert bidOrderNotCreated();
        if(orderBook[_askOrder].status != StatusOrder.CREATED) revert askOrderNotCreated();
        if(orderBook[_bidOrder].amount != orderBook[_askOrder].amount) revert notEqualAmount();
        if(orderBook[_askOrder].customer != msg.sender) revert wrongOwner();

        // Check if order types are correct

        orderBook[_askOrder].status = StatusOrder.ACCEPTED;
        orderBook[_bidOrder].status = StatusOrder.ACCEPTED;
        uint256 timeExecution = block.timestamp;

        emit bidOrderCompleted(
            orderBook[_bidOrder],
            orderBook[_askOrder],
            timeExecution
        );

    }

    function askOrderAccepted( uint256 _bidOrder, uint256 _askOrder) public {
        if(orderBook[_bidOrder].status != StatusOrder.CREATED) revert bidOrderNotCreated();
        if(orderBook[_askOrder].status != StatusOrder.CREATED) revert askOrderNotCreated();
        if(orderBook[_bidOrder].amount != orderBook[_askOrder].amount) revert notEqualAmount();
        if(orderBook[_bidOrder].customer != msg.sender) revert wrongOwner();

        orderBook[_askOrder].status = StatusOrder.ACCEPTED;
        orderBook[_bidOrder].status = StatusOrder.ACCEPTED;
        uint256 timeExecution = block.timestamp;

        emit askOrderCompleted(
            orderBook[_bidOrder],
            orderBook[_askOrder],
            timeExecution
        );
    }
}

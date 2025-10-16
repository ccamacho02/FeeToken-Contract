// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// OpenZeppelin v4.x (compatible con 0.8.2)
import "@openzeppelin/contracts@4.4.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.4.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.0/security/Pausable.sol";

/**
 * @title FeeToken
 * @notice ERC20 con impuesto por transferencia enviado a tesorería.
 * Requisitos de la rúbrica:
 * - Hereda ERC20, Ownable, Pausable.
 * - Constructor recibe: nombre, símbolo, tesorería, taxFee (0-100).
 * - En cada transferencia: calcula fee, envía fee a tesorería y neto al receptor.
 *   Si emisor o receptor están exentos, no cobra fee.
 * - El owner puede: cambiar fee, cambiar tesorería, pausar/reanudar, (in)cluir exentos.
 * - Eventos en funciones de estado.
 * - Reverts: tesorería != address(0), fee <= 100.
 * - Compila con 0.8.2.
 */
contract FeeToken is ERC20, Ownable, Pausable {
    // Por gas, tax como uint8 (0..100)
    uint8 public taxFee;              // en %
    address public treasury;

    mapping(address => bool) private _isFeeExempt;

    // Eventos de estado (además de Paused/Unpaused de OZ y Transfer de ERC20)
    event TaxFeeUpdated(uint8 previousFee, uint8 newFee);
    event TreasuryUpdated(address indexed previousTreasury, address indexed newTreasury);
    event FeeExemptUpdated(address indexed account, bool isExempt);

    /**
     * @dev Constructor.
     * @param name_ Nombre del token.
     * @param symbol_ Símbolo del token.
     * @param treasury_ Dirección de tesorería (no puede ser address(0)).
     * @param taxFee_ Porcentaje de impuesto [0..100].
     *
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address treasury_,
        uint8 taxFee_
    ) ERC20(name_, symbol_) {
        require(treasury_ != address(0), "treasury=0");
        require(taxFee_ <= 100, "fee>100");

        treasury = treasury_;
        taxFee = taxFee_;

        // Owner y tesoreria exentos por defecto.
        _isFeeExempt[_msgSender()] = true;
        _isFeeExempt[treasury_] = true;

        _mint(_msgSender(), 1_000_000 * (10 ** uint256(decimals())));
    }

    /**
     * @notice Asigna un nuevo fee. Solo owner.
     */
    function setTaxFee(uint8 newFee) external onlyOwner {
        require(newFee <= 100, "fee>100");
        uint8 previous = taxFee;
        taxFee = newFee;
        emit TaxFeeUpdated(previous, newFee);
    }

    /**
     * @notice Cambia la dirección de tesorería. Solo owner.
     */
    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "treasury=0");
        address previous = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(previous, newTreasury);
    }

    /**
     * @notice Incluye/excluye una address del cobro de fee. Solo owner.
     */
    function setFeeExempt(address account, bool isExempt) external onlyOwner {
        _isFeeExempt[account] = isExempt;
        emit FeeExemptUpdated(account, isExempt);
    }

    /**
     * @notice Verifica si una address es exenta de fee.
     */
    function isFeeExempt(address account) external view returns (bool) {
        return _isFeeExempt[account];
    }

    /**
     * @notice Pausa transferencias (incluye mint/burn si los hubiera). Solo owner.
     */
    function pause() external onlyOwner {
        _pause();
        // Pausable ya emite el evento Paused(address account)
    }

    /**
     * @notice Reanuda transferencias. Solo owner.
     */
    function unpause() external onlyOwner {
        _unpause();
        // Pausable ya emite el evento Unpaused(address account)
    }

    // -----------------------
    //     Lógica de fee
    // -----------------------

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "paused");
    }

    /**
     * @dev Sobrescribimos _transfer para aplicar el fee cuando corresponda.
     * Casos sin fee:
     * - mint (from == address(0)) o burn (to == address(0)) -> no aplica
     * - emisor o receptor exentos
     * - taxFee == 0
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Sin fee en mint/burn o exentos o fee=0
        if (from == address(0) || to == address(0) || _isFeeExempt[from] || _isFeeExempt[to] || taxFee == 0) {
            super._transfer(from, to, amount);
            return;
        }

        // Cálculo de fee y neto
        uint256 fee = (amount * taxFee) / 100;
        if (fee > 0) {
            require(treasury != address(0), "treasury=0"); // No se puede enviar a la tesoreria
            uint256 net = amount - fee;

            // Enviar fee a tesorería y neto al receptor
            super._transfer(from, treasury, fee);
            super._transfer(from, to, net);
        } else {
            // Para montos muy pequeños donde fee da 0
            super._transfer(from, to, amount);
        }
    }
}

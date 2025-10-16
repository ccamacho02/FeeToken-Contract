# Fee-on-Transfer ERC20 Token

## Descripción

Este proyecto es una implementación de un contrato inteligente para un token ERC20 en la red de Ethereum. La característica principal de este token es que aplica un impuesto (fee) configurable en cada transferencia. El monto recaudado por este impuesto se envía automáticamente a una dirección de tesorería designada.

El contrato hereda de las implementaciones seguras y probadas de OpenZeppelin para `ERC20`, `Ownable` y `Pausable`, garantizando un alto estándar de seguridad y funcionalidad.

## Características Principales

* **Estándar ERC20:** Totalmente compatible con el estándar ERC20 de tokens.
* **Impuesto por Transferencia:** Un porcentaje de cada transferencia es deducido y enviado a una dirección de tesorería.
* **Propietario (Owner):** El contrato tiene un propietario con privilegios administrativos, basado en `Ownable` de OpenZeppelin.
* **Pausable:** El propietario tiene la capacidad de pausar y reanudar todas las transferencias de tokens en caso de emergencia.
* **Administración Flexible:** El propietario puede:
    * Cambiar el porcentaje del impuesto.
    * Actualizar la dirección de la tesorería.
    * Excluir o incluir direcciones para que no se les aplique el impuesto.
* **Seguridad:** Incluye validaciones para evitar configurar una dirección de tesorería nula (`address(0)`) o un impuesto mayor al 100%.
* **Eventos:** Emite eventos para todas las acciones administrativas importantes, facilitando el seguimiento de cambios en el estado del contrato.

## Requisitos de la Actividad Cumplidos

* **✅ Hereda de `ERC20`, `Ownable` y `Pausable`:** El contrato importa y hereda correctamente de los contratos de OpenZeppelin.
* **✅ Constructor Parametrizado:** El constructor recibe `nombre`, `símbolo`, `dirección de tesorería` y `tax fee` al momento del despliegue.
* **✅ Lógica de Impuesto en Transferencias:** El impuesto se calcula y se distribuye correctamente entre la tesorería y el receptor en cada transferencia.
* **✅ Funcionalidades del Propietario:** Se han implementado todas las funciones administrativas requeridas para el `owner`.
* **✅ Emisión de Eventos:** Cada función que modifica el estado emite un evento.
* **✅ Manejo de Errores:** Se utilizan `require` para validar la dirección de la tesorería y el porcentaje del impuesto.
* **✅ Versión de Solidity:** El contrato compila exitosamente con una versión compatible con `0.8.2`.
* **✅ Despliegue en Sepolia:** El contrato ha sido diseñado para ser desplegado en la red de pruebas de Sepolia.
* **✅ Verificación en Etherscan:** El código fuente es compatible con el proceso de verificación de Etherscan.

## Cómo Probar

Para interactuar con el contrato, se puede utilizar un entorno de desarrollo como Remix.

1.  **Despliegue:** Despliega el contrato proporcionando los argumentos del constructor. Por ejemplo, para la prueba sugerida:
    * `name_`: "Fee Token"
    * `symbol_`: "FEE"
    * `treasury_`: (Una dirección de billetera que funcionará como tesorería)
    * `taxFee_`: `2` (para un 2% de impuesto)
2.  **Prueba de Transferencia:**
    * Transfiere una cantidad de tokens desde una cuenta que no sea el `owner` a otra cuenta.
    * **Ejemplo:** Al transferir 100 tokens, el receptor debería obtener 98 tokens y la tesorería 2 tokens, tal como se sugiere en la prueba.

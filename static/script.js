function openPositionModal() {
    document.getElementById("positionModal").style.display = "block";
}

function closePositionModal() {
    document.getElementById("positionModal").style.display = "none";
}

function addPosition() {
    const positionName = document.getElementById("newPositionName").value;
    if (!positionName) {
        alert("Название должности не может быть пустым!");
        return;
    }

    fetch("/add_position", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: `position_name=${encodeURIComponent(positionName)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === "success") {
            // Добавляем новую должность в выпадающий список
            const select = document.getElementById("position_id");
            const option = document.createElement("option");
            option.value = data.position_id;
            option.textContent = positionName;
            select.appendChild(option);
            alert(data.message);
            closePositionModal();
        } else {
            alert(data.message);
        }
    })
    .catch(error => alert("Ошибка при добавлении должности: " + error));
}


document.querySelectorAll("input[name='access_bases']").forEach(baseCheckbox => {
    baseCheckbox.addEventListener("change", function () {
        const additionalFieldsContainer = document.getElementById("additionalFields");
        additionalFieldsContainer.innerHTML = ""; // Очищаем старые поля

        const selectedBases = Array.from(document.querySelectorAll("input[name='access_bases']:checked"))
            .map(checkbox => checkbox.value);

        selectedBases.forEach(baseId => {
            fetch(`/get_additional_fields/${baseId}`)
                .then(response => response.json())
                .then(fields => {
                    fields.forEach(field => {
                        const label = document.createElement("label");
                        label.textContent = field.label;
                    
                        const input = document.createElement("input");
                        input.type = field.type;  // Тип из JSON
                        input.name = `additional_fields[${field.name}]`; // Генерируем уникальный name
                    
                        additionalFieldsContainer.appendChild(label);
                        additionalFieldsContainer.appendChild(input);
                    });
                    
                })
                .catch(error => console.error("Ошибка загрузки дополнительных полей:", error));
        });
    });
});
       
// Переключение видимости выпадающего списка
function toggleCheckboxes() {
    const checkboxes = document.getElementById("checkboxes");
    if (checkboxes.style.display === "block") {
        checkboxes.style.display = "none";
    } else {
        checkboxes.style.display = "block";
    }
}




// Закрытие выпадающего списка при щелчке вне его
window.onclick = function (event) {
    if (!event.target.matches('.selectBox')) {
        const checkboxes = document.getElementById("checkboxes");
        if (checkboxes.style.display === "block") {
            checkboxes.style.display = "none";
        }
    }
}




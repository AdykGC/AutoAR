<template>
    <section class="education">
        <h2>EDUCATION </h2>

        <div class="degrees">
            <div class="degree">
                <p class="p1">Suleyman Demirel University</p>
                <p>Kaskelen, Almaty Region</p>
            </div>
            <div class="degree">
                <p>Bachelor degree of Computer Science</p>
                <p>Science 2022 - 2026</p>
            </div>
        </div>

        <div class="degrees">
            <div class="degree">
                <p class="p1">Suleyman Demirel University</p>
                <p>Kaskelen, Almaty Region</p>
            </div>
            <div class="degree">
                <p>Bachelor degree of Computer Science</p>
                <p>Science 2022 - 2026</p>
            </div>
        </div>

</section>
</template>

<style scoped>
.education {
    margin: 35px 0 35px 0;
}

.education h2 {
    border-bottom: 3px solid var(--text-black);
    margin: 10px 0 5px 0;
    color: var(--text-black);
}

.education .degrees{
    margin: 5px 0 15px 0;
}

.education .degrees .degree {
    display: flex;
    margin: 0px 0 0px 0;
    justify-content: space-between;
    flex-direction: row;
}

.education .degrees .degree p {
    margin: 0px 0 0px 0;
    color: var(--text-black);
}
.education .degrees .degree .p1 {
    margin: 0px 0 0px 0;
    color: var(--text-black);
    font-weight: 700;
}

</style>
import { Router } from "express";
import { auth } from "../middleware/auth";
import { addMoney, subtractMoney, getTransactions } from "../controllers/transactionController";

const router = Router();

router.post("/add", auth, addMoney);
router.post("/subtract", auth, subtractMoney);
router.get("/:categoryId", auth, getTransactions);

export default router;

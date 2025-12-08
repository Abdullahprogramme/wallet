import { Router } from "express";
import { auth } from "../middleware/auth";
import { createCategory, getCategories, deleteCategory } from "../controllers/categoryContoller";

const router = Router();

router.post("/", auth, createCategory);
router.get("/", auth, getCategories);
router.delete("/:id", auth, deleteCategory);

export default router;
